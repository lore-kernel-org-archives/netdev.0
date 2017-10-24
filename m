From: Matthias Kaehlcke <mka@chromium.org>
Subject: Re: [PATCH] nfp: convert nfp_eth_set_bit_config() into a macro
Date: Tue, 24 Oct 2017 10:13:18 -0700
Message-ID: <20171024171318.GB96615@google.com>
References: <20171003200546.165731-1-mka@chromium.org>
 <20171003145000.53683e21@cakuba>
 <CAAMbb05G=HBQweiWqYva_9zTnQqAcwMhJ0yYBUi26T04YA4CxQ@mail.gmail.com>
 <20171004111724.29a4d7ff@cakuba.netronome.com>
 <20171024165603.GA96615@google.com>
 <20171024100356.63bcbb2f@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Manoj Gupta <manojgupta@chromium.org>,
        "David S . Miller" <davem@davemloft.net>,
        Simon Horman <simon.horman@netronome.com>,
        Dirk van der Merwe <dirk.vandermerwe@netronome.com>,
        oss-drivers@netronome.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Renato Golin <renato.golin@linaro.org>,
        Guenter Roeck <groeck@chromium.org>,
        Doug Anderson <dianders@chromium.org>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171024100356.63bcbb2f@cakuba.netronome.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

El Tue, Oct 24, 2017 at 10:03:56AM -0700 Jakub Kicinski ha dit:

> On Tue, 24 Oct 2017 09:56:03 -0700, Matthias Kaehlcke wrote:
> > > @@ -561,6 +568,6 @@ int __nfp_eth_set_speed(struct nfp_nsp *nsp, unsigned int speed)
> > >   */
> > >  int __nfp_eth_set_split(struct nfp_nsp *nsp, unsigned int lanes)
> > >  {
> > > -	return nfp_eth_set_bit_config(nsp, NSP_ETH_RAW_PORT, NSP_ETH_PORT_LANES,
> > > +	return NFP_ETH_SET_BIT_CONFIG(nsp, NSP_ETH_RAW_PORT, NSP_ETH_PORT_LANES,
> > >  				      lanes, NSP_ETH_CTRL_SET_LANES);
> > >  }  
> > 
> > Do you plan to send this as an official patch?
> 
> Sorry...  Dirk is prepping a larger series for this area of code and it
> got stuck there a bit :S

No prob, just wanted to make sure it didn't slip under the radar.

>  He says it's coming any day now...

Great, thanks!
