From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Thu, 22 May 2008 19:14:21 +0100
Message-ID: <20080522181420.GB28241@solarflare.com>
References: <4824D1E1.10007@sun.com> <20080509.154538.28321777.davem@davemloft.net> <4835A007.7020601@krogh.cc> <20080522.104145.193700531.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesper@krogh.cc, Matheos.Worku@Sun.COM, yhlu.kernel@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759144AbYEVSOm@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080522.104145.193700531.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Jesper Krogh <jesper@krogh.cc>
> Date: Thu, 22 May 2008 18:32:07 +0200
> 
> > Does this mean that I can expect every 10G card to have this limitation
> > under Linux?
> 
> For now, yes.  The transmit path itself in the generic network
> device layer is where the serialization comes from.

This is true in the general case, but can be substantially mitigated
by segmentation offload.  Unfortunately GSO doesn't help much as the
overhead of allocating the extra skbs is fairly high.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
