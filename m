From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH] forcedeth: new backoff implementation
Date: Thu, 10 Apr 2008 18:25:48 +0200
Message-ID: <200804101825.48607.netdev@axxeo.de>
References: <47FD5303.5000005@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:54378 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755638AbYDJQyA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 12:54:00 -0400
In-Reply-To: <47FD5303.5000005@nvidia.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ayaz,

You wrote:
> u32 gMainSeedSet[BACKOFF_SEEDSET_ROWS][BACKOFF_SEEDSET_LFSRS] = {

Could you make that 

static const u16 gMainSeedSet[BACKOFF_SEEDSET_ROWS][BACKOFF_SEEDSET_LFSRS] = {

> u32 gGearSeedSet[BACKOFF_SEEDSET_ROWS][BACKOFF_SEEDSET_LFSRS] = {

static const u16 gGearSeedSet[BACKOFF_SEEDSET_ROWS][BACKOFF_SEEDSET_LFSRS] = {


That should put it into the read only code segment and halve the sizes.

PS: I'm sure that one make these tables u8 by using some math tricks and 
other seeds, but that is beyond me now...


Best Regards

Ingo Oeser
