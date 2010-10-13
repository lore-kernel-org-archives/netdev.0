From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tbf/htb qdisc limitations
Date: Wed, 13 Oct 2010 06:26:49 +0000
Message-ID: <20101013062649.GA6915@ff.dom.local>
References: <AANLkTik6_C5pzx=yS=C0VQR2xfg0S57AZAn9WYiGvxe5@mail.gmail.com> <4CB1A22B.9090701@gmail.com> <AANLkTin_jPp+WEkyJkD_KZyrJ4WX_6dM5wtFNw_ixuzv@mail.gmail.com> <20101012101022.GA8578@ff.dom.local> <AANLkTikQkCcPXtRQGp=MQrjrWtae84VzbENn5x+1yC47@mail.gmail.com> <20101012215932.GA1945@del.dom.local> <4CB4DE6E.7030802@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steven Brudenell <steven.brudenell@gmail.com>,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:39766 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354Ab0JMG1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 02:27:20 -0400
Received: by bwz15 with SMTP id 15so2965925bwz.19
        for <netdev@vger.kernel.org>; Tue, 12 Oct 2010 23:27:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4CB4DE6E.7030802@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 12, 2010 at 03:17:18PM -0700, Rick Jones wrote:
>>> my burst problem is the only semi-legitimate motivation i can think
>>> of. the only other possible motivations i can imagine are setting
>>> "limit" to buffer more than 4GB of packets and setting "rate" to
>>> something more than 32 gigabit; both of these seem kind of dubious. is
>>> there something else you had in mind?
>>
>>
>> No, mainly 10 gigabit rates and additionally 64-bit stats.
>
> Any issue for bonded 10 GbE interfaces?  Now that the IEEE have ratified 
> (June) how far out are 40 GbE interfaces?  Or 100 GbE for that matter.

Alas packet schedulers using rate tables are still around 1G. Above 2G
they get less and less accurate, so hfsc is recommended.

Jarek P.
