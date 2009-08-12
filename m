From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH] Phonet: sockets list through proc_fs
Date: Wed, 12 Aug 2009 14:02:25 +0300
Message-ID: <200908121402.25920.remi.denis-courmont@nokia.com>
References: <1248177479-12669-1-git-send-email-remi.denis-courmont@nokia.com> <20090721.123449.123442701.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:20095 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932524AbZHLLCU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 07:02:20 -0400
Received: from esebh106.NOE.Nokia.com (esebh106.ntc.nokia.com [172.21.138.213])
	by mgw-mx09.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n7CB1M3T014036
	for <netdev@vger.kernel.org>; Wed, 12 Aug 2009 06:01:59 -0500
Received: from leon.remlab.net (esdhcp035231.research.nokia.com [172.21.35.231])
	by mgw-da01.ext.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n7CB2CgJ009408
	for <netdev@vger.kernel.org>; Wed, 12 Aug 2009 14:02:12 +0300
In-Reply-To: <20090721.123449.123442701.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 21 July 2009 22:34:49 ext David Miller wrote:
> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> Date: Tue, 21 Jul 2009 14:57:57 +0300
>
> > From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> >
> > This provides a list of sockets with their Phonet bind addresses an=
d
> > some socket debug informations through /proc/net/phonet.
> >
> > Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com=
>
>
> Applied.
>
> But why don't you create a pn_sock_init() function so you don't
> have to export so many things from socket.c?

I simply did not think of the sole pn_sock_seq_fops as "so many things"=
=2E.. But=20
I can change it if you think it would be better.

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

