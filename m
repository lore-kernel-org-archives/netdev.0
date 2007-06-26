From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [linux-pm] Re: [Bugme-new] [Bug 8678] New: Kernel OOPSes when suspend/resume
Date: Wed, 27 Jun 2007 00:34:16 +0200
Message-ID: <20070626223416.GB1998@elf.ucw.cz>
References: <bug-8678-10286@http.bugzilla.kernel.org/> <200706261942.14722.cijoml@volny.cz> <200706262159.05917.rjw@sisk.pl> <200706262316.15007.cijoml@volny.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-pm@lists.linux-foundation.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>
To: CIJOML <cijoml@volny.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:35028 "EHLO amd.ucw.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756526AbXFZWeZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2007 18:34:25 -0400
Content-Disposition: inline
In-Reply-To: <200706262316.15007.cijoml@volny.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> > > > > PREEMPT
> > > > > Modules linked in: michael_mic arc4 ecb blkcipher
> > > > > ieee80211_crypt_tkip xt_TCPMSS xt_tcpmss xt_tcpudp iptable_mangle
> > > > > ip_tables x_table s ppp_deflate zlib_deflate bsd_comp ppp_async
> > > > > crc_ccitt ppp_generic slhc mt2060 dvb_usb_dib0700 dib7000m dib7000p
> > > > > dvb_usb dvb_core di b3000mc dibx000_common bnep rfcomm hidp hid l2cap
> > > > > capability commoncap eeprom sr_mod sbp2 scsi_mod 8250_pci 8250
> > > > > serial_core eth1394 hci_usb bluetooth snd_intel8x0m snd_intel8x0
> > > > > snd_ac97_codec snd_seq_oss ac97_bus snd_seq_midi_event snd_seq
> > > > > snd_seq_device snd_pcm_os s snd_mixer_oss ipw2200 8139too ieee80211
> > > > > ieee80211_crypt snd_pcm snd_timer iTCO_wdt ehci_hcd mii ohci1394
> > > > > ieee1394 rtc uhci_hcd snd snd_page_alloc ide_cd i2c_i801 pcspkr cdrom

> > > > Good heavens.
> > > >
> > > > Does it oops every time?  And does the oops trace always look like
> > > > this?
> > >
> > > Hi Andrew,
> > >
> > > let's guess why I marked it Critical ;)
> >
> > Can you please retest without DRM?
> >
> > Greetings,
> > Rafael
> 
> Ehm What is DRM??? Digital Right Management????

(Direct Rendering M... part of 3d acceleration)

Just try to unload as many modules as possible, perhaps we'll find the
one causing it.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
