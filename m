From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [AX25] kernel panic
Date: Fri, 21 Mar 2008 11:22:27 +0000
Message-ID: <20080321112227.GA4524@ff.dom.local>
References: <47DF9D21.20807@free.fr> <20080318212531.GA2031@electric-eye.fr.zoreil.com> <47E0C261.3000106@free.fr> <47E17E2E.9050105@free.fr> <20080320073021.GA4037@ff.dom.local> <47E2EC1B.9070405@free.fr> <20080321002846.GA25568@ami.dom.local> <47E3855B.4060304@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@o2.pl>
To: Bernard Pidoux <bpidoux@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.186]:50338 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754794AbYCULUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 07:20:37 -0400
Received: by fk-out-0910.google.com with SMTP id 19so1823564fkr.5
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2008 04:20:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <47E3855B.4060304@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 21, 2008 at 10:52:27AM +0100, Bernard Pidoux wrote:
...
> The only difference I can see compared to the original spinlock report  
> is this line :
>
> [<c01e7409>] _raw_spin_lock+0x69/0x140

Bernard, thanks for these reports. I simply need more time to find
various places in ax25 which could matter here. Of course any
additional information could help, but these reports mostly repeat
the same. BTW, I wonder if it's possible to run this command for
closing the session which causes the bug with strace?:
strace -o strace.log a_command

Regards,
Jarek P.
