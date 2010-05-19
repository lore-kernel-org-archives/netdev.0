From: Kyle McMartin <kmcmartin@redhat.com>
Subject: sky2 poweroff screws up my network
Date: Wed, 19 May 2010 10:32:08 -0400
Message-ID: <20100519143208.GL3900@ihatethathostname.lab.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15522 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751789Ab0ESOcN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 May 2010 10:32:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

I've noticed a rather strange problem with the onboard sky2 on one of my
machines. When I halt -p it, my router stops passing traffic completely
until I kill the power to the machine entirely. If it's just been shut
down with halt -p, it recovers immediately after turning it back on,
while it's in BIOS.

Any thoughts on this? My guess is its because the sky2 shutdown puts the
nic to sleep and when the host is off, bad things happen.

regards, Kyle

