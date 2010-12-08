From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: WARNING at local_bh_enable while tcp_retransmit
Date: Wed, 08 Dec 2010 21:20:31 +0100
Message-ID: <4CFFE88F.3060200@gmail.com>
References: <20101207182308.664e171d.isloginov@gmail.com>	<4CFE9F73.1040203@gmail.com> <20101208123645.84091844.isloginov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Ilya Loginov <isloginov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f45.google.com ([209.85.215.45]:54669 "EHLO
	mail-ew0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754171Ab0LHUUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 15:20:39 -0500
Received: by ewy10 with SMTP id 10so1217029ewy.4
        for <netdev@vger.kernel.org>; Wed, 08 Dec 2010 12:20:38 -0800 (PST)
In-Reply-To: <20101208123645.84091844.isloginov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilya Loginov wrote:
> On Tue, 07 Dec 2010 21:56:19 +0100
> Jarek Poplawski <jarkao2@gmail.com> wrote:
> 
>> Hi, isn't any of your drivers disabling irqs on this path?
> 
> No. But we are in soft_irq because tcp_retransmit. So, may be,
> interrupts were really disabled.

Should be easy to check by copying this WARN_ON_ONCE from 
kernel/softirq.c:143 local_bh_enable to the beginning of
your rioth_start_xmit.

Jarek P.
