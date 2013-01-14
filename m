From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 3.0.y 0/3] rtnetlink: Fix problem with buffer allocation
Date: Mon, 14 Jan 2013 13:04:40 -0800
Message-ID: <20130114210440.GB24751@kroah.com>
References: <1357259449.2685.60.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Greg Rose <gregory.v.rose@intel.com>, stable@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1357259449.2685.60.camel@bwh-desktop.uk.solarflarecom.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 04, 2013 at 12:30:49AM +0000, Ben Hutchings wrote:
> These patches fix the problem that interface information including many
> VFs is too large for the 4K buffers used by glibc and other clients.
> This breaks many network services.
> 
> The first of these ('rtnetlink: Compute and store minimum ifinfo dump
> size') went into 3.1 and has also been included in SLE11 SP2.  The
> second and third were acked by David Miller and included in 3.2.34.
> 
> I've applied and briefly tested these changes in conjunction with a
> backport of the sfc driver to SLE11 SP3.

All now applied, thanks.

greg k-h
