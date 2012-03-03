From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Requeues
Date: Sat, 03 Mar 2012 00:48:48 -0500
Message-ID: <1330753728.4671.190.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:61770 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750711Ab2CCFsw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Mar 2012 00:48:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  I am seeing a small but significant number of requeues on
our pfifo_fast qdiscs.  I've not been able to find much on what this
means but the little I have implies it may be a problem with the
physical interfaces.  However, these are fairly high end systems with
Intel e1000 quad port cards.

We thought it might have something to do with the bonded interfaces so
we checked some other high end systems without bonded interfaces but the
same quad port cards and, lo and behold, the same small but significant
number of requeues.

Is this normal or does it indicate a problem somewhere? Thanks - John
