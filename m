From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: Need help debugging memory corruption
Date: Sun, 4 May 2008 14:55:29 -0500
Message-ID: <20080504145529.2eac672e@osprey.hogchain.net>
References: <20080503130951.091392ba@osprey.hogchain.net>
	<481DC731.5090303@gmail.com>
	<481DCE4C.9070805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Chris Snook <csnook@redhat.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost04.isp.att.net ([207.115.11.54]:45490 "EHLO
	fmailhost01.isp.att.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754119AbYEDTzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 15:55:31 -0400
In-Reply-To: <481DCE4C.9070805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 04 May 2008 16:55:08 +0200
Jarek Poplawski <jarkao2@gmail.com> wrote:

> Jarek Poplawski wrote, On 05/04/2008 04:24 PM:
> ...
> 
> > I'm definitely with less experience, so I wonder why it can't be
> > a simple race between atl1_clean_rx_ring() and something (maybe even
> > pending atl1_intr_rx()) on the other cpu writing skb while kfreeing?
> 
> 
> Hmm... atl1_intr_rx() looks impossible, so atl1_alloc_rx_buffers()?

I booted with nosmp and the bug is *much* harder to hit, but I still
hit it once out of about 10 tries.  Does the fact that I hit it once
using nosmp disprove the race theory?
