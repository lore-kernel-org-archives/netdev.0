From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net v2] sfc: report supported link speeds on SFP
 connections
Date: Wed, 8 Jun 2016 09:41:14 -0400
Message-ID: <20160608134114.GJ56933@redhat.com>
References: <1464917604-11596-1-git-send-email-jarod@redhat.com>
 <a354e801-dc3e-bae4-0dcb-f174df8b9161@solarflare.com>
 <20160606185529.GV56933@redhat.com>
 <20160607212016.GH56933@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Bert Kenward <bkenward@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160607212016.GH56933@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 07, 2016 at 05:20:16PM -0400, Jarod Wilson wrote:
> On Mon, Jun 06, 2016 at 02:55:29PM -0400, Jarod Wilson wrote:
> > On Mon, Jun 06, 2016 at 05:29:30PM +0100, Bert Kenward wrote:
> > > 7000-series SFC NICs connected with an SFP+ module currently fail to
> > > report any supported link speeds.
> > > 
> > > Reported-by: Jarod Wilson <jarod@redhat.com>
> > > Signed-off-by: Bert Kenward <bkenward@solarflare.com>
> > 
> > Had a feeling my cut might not have been quite right. Looks good to me.
> > 
> > Reviewed-by: Jarod Wilson <jarod@redhat.com>
> 
> ...however, upon testing, there's a gotcha. This results in my 10Gbps sfc
> nic reporting that it supports 40Gbps:
> 
> $ ethtool ens4f0
> Settings for ens4f0:
> 	Supported ports: [ FIBRE ]
> 	Supported link modes:   1000baseT/Full
> 	                        10000baseT/Full
> 	                        40000baseKR4/Full

This turned out to be a flub on my part. My local tree wasn't clean, had
some lingering test/debug crap in it that I thought I'd removed, but
clearly, hadn't. With that removed, we're all good here.

Tested-by: Jarod Wilson <jarod@redhat.com>

-- 
Jarod Wilson
jarod@redhat.com
