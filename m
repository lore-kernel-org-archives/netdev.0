From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: [PATCH] lro: eHEA example how to use LRO
Date: Mon, 6 Aug 2007 09:01:51 +0200
Message-ID: <200708060901.53336.ossthema@de.ibm.com>
References: <200708031441.26841.ossthema@de.ibm.com> <46B39030.7030009@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Andrew Gallatin <gallatin@myri.com>,
	Jeff Garzik <jeff@garzik.org>,
	David Miller <davem@davemloft.net>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759016AbXHFHcU@vger.kernel.org>
In-Reply-To: <46B39030.7030009@intel.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Auke,

On Friday 03 August 2007 22:29, Kok, Auke wrote:
> Jan-Bernd Themann wrote:
> > This patch shows how the generic LRO interface is used for SKB mode
> > 
> > Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
> > 
> > ---
> >  drivers/net/Kconfig             |    1 +
> >  drivers/net/ehea/ehea.h         |    9 ++++-
> >  drivers/net/ehea/ehea_ethtool.c |   15 +++++++
> >  drivers/net/ehea/ehea_main.c    |   84 +++++++++++++++++++++++++++++++++++---
> >  4 files changed, 101 insertions(+), 8 deletions(-)
> > 
> > diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> > index f8a602c..fec4004 100644
> > --- a/drivers/net/Kconfig
> > +++ b/drivers/net/Kconfig
> 
> <snip>
> 
> > +module_param(use_lro, int, 0);
> 
> Have you looked at my generic lro get/set patch that I posted this week? this 
> adds a useless module parameter while ethtool has all the structure already to 
> accomodate setting lro on/off.
> 

Yes, I saw your patch. Looks very good to me. I will modify our driver soon
to use ethtool instead of this module parameter.

Thanks for adding this support to the ethtool interface.
