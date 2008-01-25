From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 09/26] atl1: refactor tx processing
Date: Thu, 24 Jan 2008 20:08:03 -0500
Message-ID: <47993673.7040408@redhat.com>
References: <1199152804-3889-1-git-send-email-jacliburn@bellsouth.net>	<1199152804-3889-10-git-send-email-jacliburn@bellsouth.net>	<4795BE39.6000505@garzik.org>	<20080122183109.5ab80802@osprey.hogchain.net> <20080124190024.1b81238e@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	atl1-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42296 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751498AbYAYBIV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2008 20:08:21 -0500
In-Reply-To: <20080124190024.1b81238e@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Cliburn wrote:
> On Tue, 22 Jan 2008 18:31:09 -0600
> Jay Cliburn <jacliburn@bellsouth.net> wrote:
> 
>> On Tue, 22 Jan 2008 04:58:17 -0500
>> Jeff Garzik <jeff@garzik.org> wrote:
>>
> [...]
>>> for such a huge patch, this description is very tiny.  [describe]
>>> what is refactored, and why.
> 
> Is this one any better?

This satisfies me.

Acked-by: Chris Snook <csnook@redhat.com>

> From df475e2eea401f9dc18ca23dab538b99fb9e710c Mon Sep 17 00:00:00 2001
> From: Jay Cliburn <jacliburn@bellsouth.net>
> Date: Wed, 23 Jan 2008 21:36:36 -0600
> Subject: [PATCH] atl1: simplify tx packet descriptor
> 
> The transmit packet descriptor consists of four 32-bit words, with word 3
> upper bits overloaded depending upon the condition of its bits 3 and 4.
> The driver currently duplicates all word 2 and some word 3 register bit
> definitions unnecessarily and also uses a set of nested structures in its
> definition of the TPD without good cause. This patch adds a lengthy
> comment describing the TPD, eliminates duplicate TPD bit definitions,
> and simplifies the TPD structure itself. It also expands the TSO check
> to correctly handle custom checksum versus TSO processing using the revised
> TPD definitions. Finally, shorten some variable names in the transmit
> processing path to reduce line lengths, rename some variables to better
> describe their purpose (e.g., nseg versus m), and add a comment or two
> to better describe what the code is doing.
> 
> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
