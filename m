From: Gabor Burjan <buga@buvoshetes.hu>
Subject: Re: kernel oops after unloading nf_conntrack_netbios_ns_module
Date: Mon, 14 May 2007 09:16:11 +0200
Message-ID: <20070514071611.GA8864@odin.sis.hu>
References: <20070510090603.GA13059@odin.sis.hu> <20070510033411.6cf042ad.akpm@linux-foundation.org> <20070510110117.GE13059@odin.sis.hu> <4645D7CF.20707@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from odin.sis.hu ([212.92.23.29]:48060 "EHLO odin.sis.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750719AbXENHQS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2007 03:16:18 -0400
Content-Disposition: inline
In-Reply-To: <4645D7CF.20707@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 12, 2007 at 05:05:51PM +0200, Patrick McHardy wrote:
> Gabor Burjan wrote:
> > EIP is at destroy_conntrack+0x52/0x127 [nf_conntrack]
> >
> >>>nmblookup <existing_netbios_name>
> >>>cat /proc/net/ip_conntrack
> >>>
> >>>sleep 3
> >>>
> >>>rmmod nf_conntrack_netbios_ns
> 
> Thanks for the report and good testcase, the crash can only happen with
> a sleep of >= 3s after the last nmblookup packet was sent.
> 
> Can you try if this patch fixes it please?

Yes, it fixes the problem.
Thank you,

Gabor
