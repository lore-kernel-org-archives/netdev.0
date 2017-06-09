From: "Niklas =?iso-8859-1?Q?S=F6derlund?=" <niklas.soderlund@ragnatech.se>
Subject: Re: [PATCH] sh_eth: add support to change MTU
Date: Fri, 9 Jun 2017 22:27:48 +0200
Message-ID: <20170609202748.GA17461@bigcity.dyn.berto.se>
References: <20170609153034.8777-1-niklas.soderlund+renesas@ragnatech.se>
 <15374026-bf82-5b4c-7d1a-53b21dff3451@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <15374026-bf82-5b4c-7d1a-53b21dff3451@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

Thanks for your feedback.

On 2017-06-09 19:31:09 +0300, Sergei Shtylyov wrote:
> Hello!
> 
> On 06/09/2017 06:30 PM, Niklas Söderlund wrote:
> 
> > The hardware supports the MTU to be changed and the driver it self is
> > somewhat prepared to support this. This patch hooks up the callbacks to
> > be able to change the MTU from user-space.
> > 
> > Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
> [...]
> 
>    One more thing off my back, thanks! :-)
>    I'm OK with this patch in principle (but have several nits):

Will update nits and send v2 containing your Acked-by.

> 
> Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Thanks :-)

> 
> > diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> > index f68c4db656eda846..da41eda7bfada6b9 100644
> > --- a/drivers/net/ethernet/renesas/sh_eth.c
> > +++ b/drivers/net/ethernet/renesas/sh_eth.c
> [...]
> > @@ -3171,6 +3184,13 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
> >  	}
> >  	sh_eth_set_default_cpu_data(mdp->cd);
> > 
> > +	/* Datasheet states max MTU should be 2048 but due to the
> 
>    User's manual. :-)

Will update in v2.

>    Somehow I thought it supports jumbo frames but the manual doesn't confirm
> that... ah, that's EtherAVB! :-)

Yes I did look for that but could not find that for sh_eth :-)

> 
> > +	 * aliment calculations in sh_eth_ring_init() the practical
> 
>   Alignment.

Will fix in v2.

> 
> > +	 * MTU is a bit less. Maybe this can be optimized some more.
> 
>    Undoubtedly... :-)

:-)

> 
> [...]
> 
> MBR, Sergei
> 

-- 
Regards,
Niklas Söderlund
