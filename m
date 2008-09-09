From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: ixp4xx_hss: 4E1
Date: Tue, 09 Sep 2008 14:42:42 +0200
Message-ID: <m3ljy1trr1.fsf@maximus.localdomain>
References: <4f40a1df0809040045m6c5ff3d7s7d8ca2b624a0a8da@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-2?Q?Miguel_=C1ngel_=C1lvarez?=
	<alvarezcabanes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:34655 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751176AbYIIMmo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 08:42:44 -0400
In-Reply-To: <4f40a1df0809040045m6c5ff3d7s7d8ca2b624a0a8da@mail.gmail.com>
 ("Miguel =?iso-8859-2?Q?=C1ngel_=C1lvarez=22's?= message of "Thu\, 4 Sep
 2008 09\:45\:59 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

"Miguel =C1ngel =C1lvarez" <alvarezcabanes@gmail.com> writes:

> Our main purpose is to use the two HSS of NPE-A in packetized mode, t=
o
> obtain 2x4E1 channels.
>
> Our planned changes are:
> - Change the clock-rate from 2048000 to 8192000 so that we have a 4E1=
 per
> HSS instead of just an E1.
> - Change the frame_size from 256 to 1024.
> - Assign 4 PKT_NUM_PIPES instead of 1, so that we can have 4HDLC per
> HSS... that is up to 32x64kbps channels per HDLC.
>
> Are we working in the right direction?

I think so.

> We think it could be interesting to modify the driver so that each of=
 the
> channels can be activated or not, and assigned to the different HDLCs=
=2E..
> Would it be a desired behaviour to he mainstream, or should we leave =
just
> for our development?

Well... The HSS driver, especially the TDM part, is a real mess.
I plan to push the HDLC part (without TDM) into the official kernel,
the TDM part will stay in my private tree until something happens
(such as release of the firmware docs and/or source so I can remove
the hacks). But, of course, I can include your changes in my tree, if
they aren't way more hackish than mine, of course :-)
--=20
Krzysztof Halasa
