From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: Updated WE-18 (WPA) proposal
Date: Tue, 31 Aug 2004 17:04:46 -0400
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Message-ID: <20040831210446.GE31207@ruslug.rutgers.edu>
References: <20040830045441.GA7415@jm.kir.nu>
	<20040831085458.GD31207@ruslug.rutgers.edu>
	<1093966225.1464.9.camel@rootix>
	<200408311848.55628.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Jouni Malinen <jkmaline@cc.hut.fi>,
	hostap@shmoo.com, "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
	Pedro Ramalhais <ramalhais@serrado.net>, jt@hpl.hp.com,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
Content-Disposition: inline
In-Reply-To: <200408311848.55628.vkondra@mail.ru>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://sisyphus.iocaine.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Tue, Aug 31, 2004 at 06:48:48PM +0300, Vladimir Kondratiev wrote:
> On Tuesday 31 August 2004 18:33, Pedro Ramalhais wrote:
> PR> > > Intel Centrino driver is re-using chunks of HostAP, and I'm looking
>  at PR> > > doing so for the RealTek 8180 driver I am about to publish.
> PR> >
> PR> > Can someone elaborate on what "chunks" the centrino driver is using
> PR> > from hostap?
> PR> >
> PR> > Jeff what aspects are you looking to re-use from hostap?
> PR> >
> PR> > I guess we at prism54 should also see what we can re-use too then.
> PR> > Our next driver (a softmac driver) will have a lot more code since the
> PR> > MAC will need to be implemented on the driver side -- I'm not yet sure
> PR> > of the exact details as I haven't grep'd through the available code yet
> PR> > I'm wondering though -- are there any other softmac drivers out there,
> PR> > or to come soon?
> PR> >
> PR> >  Luis
> PR>
> PR> The ipw2100 driver and ipw2200 driver both use these parts of hostap
> PR> code:
> PR> RX code (i think now it's in file hostap_80211_rx.c)
> PR> little parts of the TX code (hostap_80211_tx.c)
> PR> the hostap_crypt* code for WEP.
> PR> Some IEEE802.11 related parts of header files.
> PR> The ipw2100 is beggining to use hostap_crypt_tkip and hostap_crypt_ccmp
> PR> for WPA and WPA2.
> PR>
> PR> I think that's it. Better ask James Ketrenos, he is one of the
> PR> developers at intel.
> 
> Luis,
> please correct me if I'm wrong. It seems to me that softmac drivers will need 
> significant changes relative to the model that HostAP employ.

I am not sure as:

1. I haven't yet gone through hostap code besides wpa_supplicant
2. I haven't yet gone through the available softmac code:

http://www.dse.co.nz/isroot/dse/support/XH8196-linux.zip

Only once I have done both will I be able to tell. My guess yes
as I do not think hostap is softmac based.

> Also, many 
> changes dictated by QoS (TGe), if one want to really implement it. Will your 
> product support TGe?

Again, 2.

> May be, we need to do design for generic "softmac" that will be then used with 
> different PHY's. 

That's where I was going with my previous e-mail.

> Question is, whether we can formally describe boundary 
> between softmac and PHY.

We need as much public information available on softmac and review, or
have someone experienced enough in this field to talk up.

> I am interesting in joining this "softmac" development, as I will do some 
> other .11 card which is "softmac". Can't reveal details yet, but we may 
> discuss softmac issues without disclosing private info (I don't want to lose 
> my job).

Well at least this confirms another card will be softmac based, and
hence the possible need for code sharing.

-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
