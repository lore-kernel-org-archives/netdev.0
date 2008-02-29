From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [PATCH (resend)][EBTABLES]: Fix alignment checks in
	ebt_among.ko module.
Date: Fri, 29 Feb 2008 18:23:13 +0100
Message-ID: <1204305793.2923.12.camel@localhost.localdomain>
References: <47C7C23C.2050100@openvz.org> <47C7FF31.1060108@trash.net>
	 <Pine.LNX.4.64.0802291639390.24056@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Pavel Emelyanov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0802291639390.24056@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Op vr, 29-02-2008 te 16:40 +0100, schreef Jan Engelhardt:
> > It seems the kernel is correct and userspace is doing it
> > wrong, so I think userspace should be fixed instead.
> > The problem with your patch is that is causes misalignment
> > for following structures that contain u64 members.
> 
> ebt_among is a true mess! It hinders my efforts to port ebtables
> to xtables, but I could of course use a hack and will likely
> do just that.

Ebtables' dynamic memory allocation scheme is probably not portable to
iptables. I agree the fix is in userspace. Anyway, I think the author of
that module did a great job and provided a very useful and often-used
functionality.

Bart


