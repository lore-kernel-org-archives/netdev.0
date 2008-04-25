From: David Miller <davem@davemloft.net>
Subject: Re: Socket buffer sizes with autotuning
Date: Fri, 25 Apr 2008 00:46:34 -0700 (PDT)
Message-ID: <20080425.004634.27450322.davem@davemloft.net>
References: <65634d660804242234w66455bedve44801a98e3de9d9@mail.gmail.com>
	<20080424.233643.250240829.davem@davemloft.net>
	<65634d660804250042y5786e305t456f2154a6bcf040@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, johnwheffner@gmail.com, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48996
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756580AbYDYHqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 03:46:34 -0400
In-Reply-To: <65634d660804250042y5786e305t456f2154a6bcf040@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Tom Herbert" <therbert@google.com>
Date: Fri, 25 Apr 2008 00:42:03 -0700

> If NIC is interrupt driven, enough data must be queued to span
> consecutive interrupts.  So for instance if a 10G NIC is generating an
> interrupt every 100us, about 125,000 bytes needs to queued at each
> interrupt to prevent starvation-- this doesn't translate to a fixed
> number of packets.  Limiting by packets seems somewhat ad hoc; if the
> limit is to small and the link will be starved, too big and
> over-queuing results.

Yes, however when packets are small the limiting factor becomes
per-transfer transaction related overhead.
