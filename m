From: "Gustavo F. Padovan" <gustavo@padovan.org>
Subject: Re: [BUG net-2.6] bluetooth/rfcomm : sleeping function called from
 invalid context at mm/slub.c:1719
Date: Sun, 4 Oct 2009 18:06:35 +0000
Message-ID: <20091004180635.GA11272@vigoh>
References: <4AC59D8A.6000102@hartkopp.net>
 <a8e1da0910020401m2fb8493ax95ff55a3b66131a5@mail.gmail.com>
 <4AC6247E.7050308@hartkopp.net>
 <20091003070622.GA4110@darkstar>
 <4AC71CAA.9090704@hartkopp.net>
 <a8e1da0910032026m66200c08jf9201bbfe34b2f30@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Hartkopp <oliver@hartkopp.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-bluetooth@vger.kernel.org,
	"Gustavo F. Padovan" <gustavo@las.ic.unicamp.br>
To: Dave Young <hidave.darkstar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f212.google.com ([209.85.217.212]:43456 "EHLO
	mail-gx0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757603AbZJDSHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2009 14:07:15 -0400
Content-Disposition: inline
In-Reply-To: <a8e1da0910032026m66200c08jf9201bbfe34b2f30@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi all,

* Dave Young <hidave.darkstar@gmail.com> [2009-10-04 11:26:17 +0800]:

> 
> I can reproduce the bug.
> 
> It's probably caused by the l2cap changes by  Gustavo F. Padovan
> <gustavo@las.ic.unicamp.br>, I didn't see such problem after reverting
> Gustavo's patch series.

I can't reproduce the bug. I'm trying to reproduce it to figure out what of
my changes cause it.

I' running

$ dund -snu -i 00:11:67:CD:0F:CB # to pretend to be dialup/telephone

and on the other side 

$ rfcomm bind 0 00:11:67:CD:0F:CB 1
$ wvdial  # wvdial to /dev/rfcomm0

Both sides are on the same machine. Do you see any real difference
between my try and the call that get the bug?


--
Gustavo F. Padovan
