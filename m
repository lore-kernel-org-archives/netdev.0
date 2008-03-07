From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Thu, 6 Mar 2008 19:58:06 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0803061956390.532@schroedinger.engr.sgi.com>
References: <20080304.161003.129716254.davem@davemloft.net>
 <Pine.LNX.4.64.0803051257030.30742@schroedinger.engr.sgi.com>
 <20080306025758.GB27150@wotan.suse.de> <Pine.LNX.4.64.0803061453360.16212@schroedinger.engr.sgi.com>
 <20080307022355.GB21185@wotan.suse.de> <Pine.LNX.4.64.0803061825120.29527@schroedinger.engr.sgi.com>
 <20080307023223.GD21185@wotan.suse.de> <Pine.LNX.4.64.0803061841220.29959@schroedinger.engr.sgi.com>
 <20080307031044.GF21185@wotan.suse.de> <Pine.LNX.4.64.0803061916580.30259@schroedinger.engr.sgi.com>
 <20080307032251.GG21185@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yanmin_zhang@linux.intel.com,
	dada1@cosmosbay.com
To: Nick Piggin <npiggin@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:38450 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750718AbYCGD6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 22:58:23 -0500
In-Reply-To: <20080307032251.GG21185@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 7 Mar 2008, Nick Piggin wrote:

> Where do I argue that it reduces cacheline contention? All arguments
> I made apply to a UP system equally.

Huh? I thought you wanted to avoid cacheline alignment on UP to save 
memory?


