From: Guillaume Chazarain <guichaz@yahoo.fr>
Subject: Re: PROBLEM: oops, Linus tree: 2.6.23-g4fa4d23f, BUG: unable to
 handle kernel NULL pointer dereference at virtual address 00000004
Date: Sun, 21 Oct 2007 12:17:02 +0200
Message-ID: <20071021121702.4816ca1f@inria.fr>
References: <4719B727.7090908@oak.selfip.net>
	<Pine.LNX.4.64.0710201246540.18815@twin.jikos.cz>
	<3d8471ca0710200432h3607b0a0i9169884ebec3b940@mail.gmail.com>
	<471AE0B0.4060600@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Kosina <jikos@jikos.cz>, Dave Haywood <tla@oak.selfip.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Pavel Emelyanov <xemul@openvz.org>
To: Coly Li <coyli@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g19.free.fr ([212.27.42.29]:58880 "EHLO smtp3-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751016AbXJUKUG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 06:20:06 -0400
In-Reply-To: <471AE0B0.4060600@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le Sun, 21 Oct 2007 13:16:32 +0800,
Coly Li <coyli@suse.de> a =C3=A9crit :

> > This should be fixed in recent git by
> > http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;=
a=3Dcommit;h=3D9b013e05e0289c190a53d78ca029e2f21c0e4485
> >=20
> Maybe we encounter same condition, at least the symbol name is same -=
- sock_setsockopt.

> [ 4327.550291] EFLAGS: 00010282   (2.6.23-bigsmp-g4fa4d23f #6)

You are testing a kernel that does not contain the aforementioned fix,
so you should update your git checkout (using a kernel that can connect
to the Internet ;-) ) and test the new kernel.

Thanks.

--=20
Guillaume
