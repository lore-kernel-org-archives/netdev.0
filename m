From: Jiri Pirko <jpirko@redhat.com>
Subject: re commit d4f73c8e459d355e10051174d859ffd0ef5764c0
Date: Mon, 15 Aug 2011 14:12:14 +0200
Message-ID: <20110815121213.GA2013@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephan.baerwolf@tu-ilmenau.de
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23925 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752827Ab1HOMM1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Aug 2011 08:12:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Francois.

Looking at mentioned commit, Not sure if the functionality is correct.
Your patch message says:

The non-tagged interface is filtered out as soon as a tagged
(!= 0) interface is created. Its traffic appears again when an
zero-tagged interface is created.

I would presume non-tagged packet would not be filtered any time.
Removing "WORD_REG_BITS_ON(MCFG_RTGOPT, &regs->MCFG);" should probably
do the trick.

Thanks.

Jirka

