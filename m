From: Shuya MAEDA <maeda-sxb@necst.nec.co.jp>
Subject: Re: Patch "[PKT_SCHED]: PSCHED_TADD() and PSCHED_TADD2() can result,tv_usec
 >= 1000000" seems wrong
Date: Wed, 19 Jul 2006 16:49:11 +0900
Message-ID: <44BDE3F7.4000507@necst.nec.co.jp>
References: <44B7A76C.4010703@yahoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([210.143.35.51]:50861 "EHLO
	tyo201.gate.nec.co.jp") by vger.kernel.org with ESMTP
	id S932442AbWGSHtR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 03:49:17 -0400
To: Guillaume Chazarain <guichaz@yahoo.fr>
In-Reply-To: <44B7A76C.4010703@yahoo.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

> In PSCHED_TADD2, if delta is less than tv.tv_usec (so, less than 
> USEC_PER_SEC too) then tv_res will be before tv. The
> affectation (tv_res).tv_usec = __delta; is wrong. The same applies to 
> PSCHED_TADD.

You are right. It is my mistake.

> I think the correct fix is simply to restore the original code and 
> change the 'if' in a 'while'.

In Guillaume's patch,
"while (__delta > USEC_PER_SEC){ ... }", but I think it should be
"while (__delta >= USEC_PER_SEC){ ... }". Is it right?

Thank you very much.
-- 
Shuya MAEDA
