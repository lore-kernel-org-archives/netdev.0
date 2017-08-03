From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 3/5] net: stmmac: Add Adaptrum Anarion GMAC glue layer
Date: Thu, 3 Aug 2017 18:22:47 -0500
Message-ID: <20170803232247.rixl3yhpww5woihg@rob-hp-laptop>
References: <20170728220707.13960-1-alex.g@adaptrum.com>
 <20170728220707.13960-4-alex.g@adaptrum.com>
 <20170728.190155.457209566729295513.davem@davemloft.net>
 <b3a51afc-1eae-66ea-f20e-a09cd8289c1b@adaptrum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org,
        mark.rutland@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org
To: Alex <alex.g@adaptrum.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <b3a51afc-1eae-66ea-f20e-a09cd8289c1b@adaptrum.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 31, 2017 at 08:11:00AM -0700, Alex wrote:
> Hi David,
> 
> On 07/28/2017 07:01 PM, David Miller wrote:
> > From: Alexandru Gagniuc <alex.g@adaptrum.com>
> > Date: Fri, 28 Jul 2017 15:07:03 -0700
> > 
> > > Before the GMAC on the Anarion chip can be used, the PHY interface
> > > selection must be configured with the DWMAC block in reset.
> > > 
> > > This layer covers a block containing only two registers. Although it
> > > is possible to model this as a reset controller and use the "resets"
> > > property of stmmac, it's much more intuitive to include this in the
> > > glue layer instead.
> > > 
> > > At this time only RGMII is supported, because it is the only mode
> > > which has been validated hardware-wise.
> > > 
> > > Signed-off-by: Alexandru Gagniuc <alex.g@adaptrum.com>
> > 
> > I don't see how this fits into any patch series at all.  If this is
> > part of a series you posted elsewhere, you should keep netdev@ on
> > all such postings so people there can review the change in-context.
> 
> I used the --cc-cmd option to send-email. I'll be sure to CC netdev@ on
> [PATCH v2].

The problem is your series spans several subsystems and it's not 
clear who you intend to apply these. There aren't really any hard 
dependencies between the patches, so they could all go thru different 
trees. But you need to state that at least implicitly by sending the 
patches TO who should apply them and CC the rest (and get_maintainers.pl 
doesn't really help with that aspect). Or just don't send them in a 
series if there's not an inter-dependency of the patches. Normally 
bindings and a driver do go together and I'll ack the binding.

Rob
