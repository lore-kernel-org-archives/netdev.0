From: Wolfgang Denk <wd@denx.de>
Subject: Re: [PATCH 1/2 v4] fs_enet/mii-fec.c: fix MII speed calculation
Date: Fri, 17 Jul 2009 14:32:45 +0200
Message-ID: <20090717123245.4595F832E416@gemini.denx.de>
References: <1247671133-12148-1-git-send-email-wd@denx.de>
	<1247780546-4426-1-git-send-email-wd@denx.de>
	<20090717093307.GB3150@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-reply-to: <20090717093307.GB3150@pengutronix.de>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Dear Wolfram Sang,

In message <20090717093307.GB3150@pengutronix.de> you wrote:
> 
...
> > @@ -188,6 +209,12 @@ static struct of_device_id fs_enet_mdio_fec_match[] = {
> >  	{
> >  		.compatible = "fsl,pq1-fec-mdio",
> >  	},
> > +#if defined(CONFIG_PPC_MPC512x)
> > +	{
> > +		.compatible = "fsl,mpc5121-fec-mdio",
> > +		.data = mpc5xxx_get_bus_frequency,
> > +	},
> > +#endif
>
> Grepping through 'drivers/*' I see that #ifdefing compatible-entries is highly
> uncommon (just 3 hits). I think a guideline would be useful. Most people like
> to avoid #ifdefs at any cost, while I personally think it doesn't spoil
> readability too much here. Other opinions?

An older version of the patch tried to "hide" the ifdef in a 512x
specific header, so at least common code would remain clean, but I
agree with Grant that this current version looks cleaner globally.

Best regards,

Wolfgang Denk

-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: (+49)-8142-66989-10 Fax: (+49)-8142-66989-80 Email: wd@denx.de
"You can have my Unix system when you  pry  it  from  my  cold,  dead
fingers."                                                - Cal Keegan
