From: Pedro Ramalhais <ramalhais@serrado.net>
Subject: Re: Updated WE-18 (WPA) proposal
Date: Tue, 31 Aug 2004 16:33:47 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1093966225.1464.9.camel@rootix>
References: <20040830045441.GA7415@jm.kir.nu>
	 <20040830165026.GD29492@bougret.hpl.hp.com> <413363CB.7060807@pobox.com>
	 <20040830174215.GA32132@bougret.hpl.hp.com> <41336A28.9010608@pobox.com>
	 <20040830220105.GY22126@ruslug.rutgers.edu> <4133A811.1010009@pobox.com>
	 <20040831085458.GD31207@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
        "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>, jt@hpl.hp.com,
        Jouni Malinen <jkmaline@cc.hut.fi>, netdev@oss.sgi.com,
        hostap@shmoo.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>
In-Reply-To: <20040831085458.GD31207@ruslug.rutgers.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-08-31 at 09:54, Luis R. Rodriguez wrote:
> On Mon, Aug 30, 2004 at 06:20:01PM -0400, Jeff Garzik wrote:
> > Luis R. Rodriguez wrote:
> > >On Mon, Aug 30, 2004 at 01:55:52PM -0400, Jeff Garzik wrote:
> > >
> > >>Jean Tourrilhes wrote:
> > >
> > >
> > ><-- snip -->
> > >
> > >>>	Also, I'm not clear how the stuff in wireless-2.6 is supposed
> > >>>to trickle into the other trees (netdev-2.6, -mm and Linus's), and how
> > >>>to better link it with the CVS of the various drivers involved.
> > >>
> > >>Less of a trickle than a flood:  wireless-2.6 should be the target for 
> > >>development of shared wireless stack code.  As several drivers are 
> > >>currently using bits of HostAP, for example, wireless-2.6 should be a 
> > >>focal point for patches that modify these drivers to instead share the 
> > >>same code.
> > >>
> > >>Once this generic work is done, it would get pushed all at once to 
> > >>netdev-2.6, where it would receive testing in -mm.  Then, later, pushed 
> > >>to mainline.
> > >>
> > >>	Jeff
> > >
> > >
> > >Beides wpa_supplicant from hostap code (which is actually going into
> > >WE18) what other code re-use is on the roadmap as of yet for wireless-2.6?
> > 
> > Intel Centrino driver is re-using chunks of HostAP, and I'm looking at 
> > doing so for the RealTek 8180 driver I am about to publish.
> 
> Can someone elaborate on what "chunks" the centrino driver is using
> from hostap?
> 
> Jeff what aspects are you looking to re-use from hostap?
> 
> I guess we at prism54 should also see what we can re-use too then.
> Our next driver (a softmac driver) will have a lot more code since the
> MAC will need to be implemented on the driver side -- I'm not yet sure
> of the exact details as I haven't grep'd through the available code yet
> I'm wondering though -- are there any other softmac drivers out there,
> or to come soon?
> 
> 	Luis

The ipw2100 driver and ipw2200 driver both use these parts of hostap
code:
RX code (i think now it's in file hostap_80211_rx.c)
little parts of the TX code (hostap_80211_tx.c)
the hostap_crypt* code for WEP.
Some IEEE802.11 related parts of header files.
The ipw2100 is beggining to use hostap_crypt_tkip and hostap_crypt_ccmp
for WPA and WPA2.

I think that's it. Better ask James Ketrenos, he is one of the
developers at intel.
-- 
Pedro Ramalhais <ramalhais@serrado.net>
