From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: Re: ATM firestream bug
Date: Sun, 01 Oct 2006 12:56:41 -0400
Message-ID: <200610011656.k91GufHC007522@cmf.nrl.navy.mil>
References: <451FD494.1090804@garzik.org>
Cc: Netdev List <netdev@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:5780 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S1751294AbWJAQ5I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Oct 2006 12:57:08 -0400
To: Jeff Garzik <jeff@garzik.org>
In-reply-to: <451FD494.1090804@garzik.org> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In message <451FD494.1090804@garzik.org>,Jeff Garzik writes:
>1) not safe on 64-bit

firestream is not the only driver that's likely 32-bit safe only.
zatm, nicstar, horizon and ambassdor all use virt_to_bus().

>2) variable 'tmc0' is indeed potentially used uninit'd, in particular if 
>make_rate() returns an error (use occurs before error check).

i will fix this later.
