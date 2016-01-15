From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH v3 2/3] gianfar: Delete unnecessary variable
 initialisations in gfar_ethflow_to_filer_table()
Date: Fri, 15 Jan 2016 15:15:10 +0300
Message-ID: <20160115121510.GJ4764@mwanda>
References: <566ABCD9.1060404@users.sourceforge.net>
 <56866E7F.8080609@users.sourceforge.net>
 <5698C53C.8060204@users.sourceforge.net>
 <5698C61A.90504@users.sourceforge.net>
 <20160115102947.GI4764@mwanda>
 <5698D949.6000404@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5698D949.6000404@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 15, 2016 at 12:34:33PM +0100, SF Markus Elfring wrote:
> >> +++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
> >> @@ -768,12 +768,12 @@ static void ethflow_to_filer_rules (struct gfar_private *priv, u64 ethflow)
> >>  static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow,
> >>  				       u64 class)
> >>  {
> >> -	unsigned int last_rule_idx = priv->cur_filer_idx;
> >> +	unsigned int last_rule_idx;
> > 
> > This is a write only variable.  We can just remove it.
> 
> Can a static source code analysis tool like the software "http://smatch.sourceforge.net/"
> detect that such a variable is not read by this function implementation so far?

Yeah.  That's a good idea.  I will do that.

> https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/tree/drivers/net/ethernet/freescale/gianfar_ethtool.c?id=b75ec3af27bf011a760e2f44eb25a99b6fbb0fb3#n850
> 
> Does this place indicate an unwanted value assignment as a leftover,
> or are there any other actions missing?

I think it's just an extra variable and you can just delete it.

regards,
dan carpenter

