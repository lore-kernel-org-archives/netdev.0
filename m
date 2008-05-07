From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.25: racoon does not work without ipv6 any more
Date: Wed, 7 May 2008 16:36:13 -0700
Message-ID: <20080507163613.5ff56766.akpm@linux-foundation.org>
References: <20080422234246.GA17735@swan.nt.tuwien.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Kazunori MIYAZAWA <kazunori@miyazawa.org>,
	netdev@vger.kernel.org
To: Thomas Zeitlhofer <tzeitlho+lkml@nt.tuwien.ac.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40217 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753526AbYEGXg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 19:36:58 -0400
In-Reply-To: <20080422234246.GA17735@swan.nt.tuwien.ac.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Apr 2008 01:42:47 +0200
Thomas Zeitlhofer <tzeitlho+lkml@nt.tuwien.ac.at> wrote:

> Hello,
> 
> commit df9dcb4588aca9cc243cf1f3f454361a84e1cbdb breaks racoon if the
> kernel is compiled _without_ ipv6 support. 
> 
> In this case, racoon fails in phase 2 with:
> 
> 	racoon: ERROR: pfkey UPDATE failed: Protocol not supported
> 	racoon: ERROR: pfkey ADD failed: Protocol not supported
> 
> Up to 2.6.24, racoon worked fine without ipv6 support in the kernel and
> reverting the commit above restores the old behavior.
> 

(cc's added)
