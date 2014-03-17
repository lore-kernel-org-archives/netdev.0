From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [net-next 03/16] i40evf: Support RSS option in ethtool
Date: Mon, 17 Mar 2014 18:55:22 +0000
Message-ID: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D6556FAE5@FMSMSX113.amr.corp.intel.com>
References: <1395060316-16897-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1395060316-16897-4-git-send-email-jeffrey.t.kirsher@intel.com>
 <CAJZOPZJWCDGcC3hWAVsLkN8LSY-7GifDSKN6OhDRjgwFpjtuSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Sullivan, Catherine" <catherine.sullivan@intel.com>
To: Or Gerlitz <or.gerlitz@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:33876 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750706AbaCQSzz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 14:55:55 -0400
In-Reply-To: <CAJZOPZJWCDGcC3hWAVsLkN8LSY-7GifDSKN6OhDRjgwFpjtuSw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: Or Gerlitz [mailto:or.gerlitz@gmail.com]
> Sent: Monday, March 17, 2014 7:40 AM
> To: Kirsher, Jeffrey T
> Cc: David Miller; Williams, Mitch A; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com; Sullivan, Catherine
> Subject: Re: [net-next 03/16] i40evf: Support RSS option in ethtool
> 
> On Mon, Mar 17, 2014 at 2:45 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > From: Mitch Williams <mitch.a.williams@intel.com>
> >
> > Add support for viewing and modifying RSS hash options and RSS hash
> > look-up table programming through ethtool.
> [...]
> 
> FWIW, this commit does more... wouldn't it be worth dropping some
> words on that on that change-log?
> 

Well, Or, I'm not sure really what to say. I added code to change which hashing options RSS would use, and code to change the RSS lookup table.

Looks like Ben has some comments, so we'll have to respin this anyway. I'm happy to change the description, just wondering what you'd like to see here.

-Mitch

> [...]
> >  static struct ethtool_ops i40evf_ethtool_ops = {
> >         .get_settings           = i40evf_get_settings,
> >         .get_drvinfo            = i40evf_get_drvinfo,
> > @@ -378,6 +687,12 @@ static struct ethtool_ops i40evf_ethtool_ops = {
> >         .set_msglevel           = i40evf_set_msglevel,
> >         .get_coalesce           = i40evf_get_coalesce,
> >         .set_coalesce           = i40evf_set_coalesce,
> > +       .get_rxnfc              = i40evf_get_rxnfc,
> > +       .set_rxnfc              = i40evf_set_rxnfc,
> > +       .get_rxfh_indir_size    = i40evf_get_rxfh_indir_size,
> > +       .get_rxfh_indir         = i40evf_get_rxfh_indir,
> > +       .set_rxfh_indir         = i40evf_set_rxfh_indir,
> > +       .get_channels           = i40evf_get_channels,
> >  };
