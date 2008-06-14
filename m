From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM] iphase: move suni_priv to suni.h
Date: Sat, 14 Jun 2008 17:23:48 -0400
Message-ID: <200806142123.m5ELNmfK004254@cmf.nrl.navy.mil>
References: <48481126.1000204@dti2.net>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@vger.kernel.org
To: jorge@dti2.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:45609 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756657AbYFNVYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jun 2008 17:24:02 -0400
In-reply-to: <48481126.1000204@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <48481126.1000204@dti2.net>,"Jorge Boncompte [DTI2]" writes:
>
>Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>

i am not thrilled about iphase digging at the internals of the suni
module, but i would prefer not to have a duplicate struct.  i will
submit this with the next batch of atm patches.  btw, i moved the
struct suni_priv inside the #ifdef KERNEL since userspace cant
make any use of the struct.

