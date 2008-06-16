From: =?ISO-8859-1?Q?S=E9guier_R=E9gis?= <rseguier@e-teleport.net>
Subject: Re: [PATCH] net: via-velocity.c fix sleep-with-spinlock bug during
 MTU change
Date: Mon, 16 Jun 2008 19:21:40 +0200
Message-ID: <4856A124.1030701@e-teleport.net>
References: <20080531184615.350bac00@infradead.org> <20080603134019.df2f51d4.akpm@linux-foundation.org> <20080603215155.GA9712@electric-eye.fr.zoreil.com> <20080604215909.GA17446@electric-eye.fr.zoreil.com> <20080614212341.GA12976@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.e-teleport.net ([213.190.83.68]:42913 "EHLO
	mail.imsnet.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751439AbYFPRz7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 13:55:59 -0400
In-Reply-To: <20080614212341.GA12976@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rancois Romieu a =E9crit :
> Francois Romieu <romieu@fr.zoreil.com> :
> [...context available from http://lkml.org/lkml/2008/5/31/251 ...]
>
> R=E9gis, I need your help.
>
> Can you give the patchkit below a try and check if the change of mtu
> works correctly ?
>
> http://userweb.kernel.org/~romieu/via-velocity/2.6.26-rc6/
>
> or:
>
> git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git v=
elocity
>
>  =20
With the patchkit, the driver doesn't work anymore.
I think there is an error in TX, paquets don't arrive to other equipmen=
t.
RX seem to work fine, I could see ingoming paquets.

--=20
R=E9gis
