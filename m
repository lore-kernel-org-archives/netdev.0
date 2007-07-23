From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 06/12 -Rev2] rtnetlink changes.
Date: Mon, 23 Jul 2007 08:24:58 +0530
Message-ID: <OF5ECADA10.ABB9C3B0-ON65257321.000FEF47-65257321.001004EC@in.ibm.com>
References: <46A38F8D.6080109@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, davem@davemloft.net, sri@us.ibm.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46A38F8D.6080109@trash.net>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Hi Patrick,

Patrick McHardy <kaber@trash.net> wrote on 07/22/2007 10:40:37 PM:

> Krishna Kumar wrote:
> > diff -ruNp org/include/linux/if_link.h rev2/include/linux/if_link.h
> > --- org/include/linux/if_link.h   2007-07-20 16:33:35.000000000 +0530
> > +++ rev2/include/linux/if_link.h   2007-07-20 16:35:08.000000000 +0530
> > @@ -78,6 +78,8 @@ enum
> >     IFLA_LINKMODE,
> >     IFLA_LINKINFO,
> >  #define IFLA_LINKINFO IFLA_LINKINFO
> > +   IFLA_TXBTHSKB,      /* Driver support for Batch'd skbs */
> > +#define IFLA_TXBTHSKB IFLA_TXBTHSKB
>
>
> Ughh what a name :) I prefer pronouncable names since they are
> much easier to remember and don't need comments explaining
> what they mean.
>
> But I actually think offering just an ethtool interface would
> be better, at least for now.

Great, I will remove /sys and rtnetlink and keep the Ethtool i/f.

Thanks,

- KK
