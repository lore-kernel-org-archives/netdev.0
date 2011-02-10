From: Ian Molton <ian.molton@collabora.co.uk>
Subject: [RFD][PATCH] Add JMEMCMP to Berkeley Packet Filters
Date: Thu, 10 Feb 2011 12:14:46 +0000
Message-ID: <1297340087-10963-1-git-send-email-ian.molton@collabora.co.uk>
Cc: rdunlap@xenotime.net, isdn@linux-pingi.de, paulus@samba.org,
	arnd@arndb.de, davem@davemloft.net, herbert@gondor.apana.org.au,
	ebiederm@xmission.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.128.226]:45654 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934Ab1BJMPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 07:15:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

This patch implements an extension for BPF to allow filter programs to use a
data section, along with a MEMCMP instruction.

There are a few issues noted in the patch itself, which can easily be
addressed, and I would like to check wether sk_run_filter is ever expected to
be called from a context that cannot sleep (I dont think it is).

I think the patch should probably be split into a patch to add data sections
and one adding the JMEMCMP instruction, but that can be done after some review! 

-Ian
