From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCHv7 iptables] Interface group match
Date: Sat, 01 Dec 2007 22:19:05 +0100
Message-ID: <4751CFC9.6000607@o2.pl>
References: <11963527094077-git-send-email-panther@balabit.hu> <11963527103201-git-send-email-panther@balabit.hu> <1196352710402-git-send-email-panther@balabit.hu> <11963527101876-git-send-email-panther@balabit.hu> <11963527103391-git-send-email-panther@balabit.hu> <11963527102332-git-send-email-panther@balabit.hu> <11963527101629-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:37242 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751975AbXLAVRf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 16:17:35 -0500
In-Reply-To: <11963527101629-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Laszlo Attila Toth wrote, On 11/29/2007 05:11 PM:
...

> Index: extensions/libxt_ifgroup.man
> ===================================================================
> --- extensions/libxt_ifgroup.man	(revision 0)
> +++ extensions/libxt_ifgroup.man	(revision 0)
> @@ -0,0 +1,36 @@
> +Maches packets on an interface if it is in the same interface group


  +Matches packets on an interface if it is in the same interface group

> +as specified by the
> +.B "--ifgroup-in"
> +or
> +.B "--ifgroup-in"


  +.B "--ifgroup-out"

> +parameter. If a mask is also specified, the masked value of
> +the inteface's group must be equal to the given value of the


  +the interface's group must be equal to the given value of the

> +.B "--ifgroup-in"
> +or
> +.B "--ifgroup-out"
> +parameter to match. This match is available in all tables.
> +.TP
> +.BR "[!] --ifgroup-in \fIgroup[/mask]\fR"
> +This specifies the interface group of input interface and the optional mask.
> +Valid only in the in the


  +Valid only in the

> +.B PREROUTING
> +and
> +.B INPUT
> +and
> +.B FORWARD
> +chains, and user-defined chains which are only called from those
> +chains. 
> +.TP
> +.BR "[!] --ifgroup-out \fIgroup[/mask]\fR"
> +This specifies the interface group of out interface and the optional mask.


  +This specifies the interface group of output interface and the optional mask.

> +Valid only in the in the
> +.B FORWARD
> +and
> +.B OUTPUT
> +and
> +.B POSTROUTING
> +chains, and user-defined chains which are only called from those
> +chains. 
> +.RS
> +.PP
> +

Regards,
Jarek P.
