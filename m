From: Werner Almesberger <werner@almesberger.net>
Subject: Re: [PATCH 2/2] at86rf230: change irq handling to prevent lockups
 with edge type irq
Date: Mon, 8 Apr 2013 12:35:21 -0300
Message-ID: <20130408153521.GH28141@ws>
References: <cover.1365107512.git.sascha@ps.nvbi.de>
 <57c67195742f5e7482dc57f5a05b6d69156b00d2.1365107512.git.sascha@ps.nvbi.de>
 <20130405035949.GC29789@ws>
 <20130405105158.GD29789@ws>
 <f947aa8f-75bc-4314-bb92-289d9f2bc93d@email.android.com>
 <20130406142035.GG28141@ws>
 <5161DC96.6030905@ps.nvbi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: Sascha Herrmann <sascha@ps.nvbi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.openmoko.org ([88.198.124.205]:45157 "EHLO
	mail.openmoko.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936341Ab3DHPge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 11:36:34 -0400
Content-Disposition: inline
In-Reply-To: <5161DC96.6030905@ps.nvbi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sascha Herrmann wrote:
> Maybe one way to eliminate the extra latency of the second register read
> would be to split the interrupt handling function into a generic part
> and two different functions to handle the different types of interrupts:

Yes, if you want to optimize the number of register accesses and
work queue invocations, splitting the paths that touch interrupts
seems to be the most straightforward approach.

> If you think the solution above would be ok, I could try to send a
> version which allows the configuration of trigger type and level.

Sounds good to me. Pity the irq_get_irq_type() you mentioned
doesn't exist. That would have made things a bit nicer.

- Werner
