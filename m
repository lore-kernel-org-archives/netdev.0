From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [Bugme-new] [Bug 11469] New: TUN with 1024 neighbours: ip6_dst_lookup_tail NULL crash
Date: Fri, 5 Sep 2008 15:41:50 +0400
Message-ID: <20080905114146.GA29408@2ka.mipt.ru>
References: <bug-11469-10286@http.bugzilla.kernel.org/> <20080831111304.d57b9f5a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	rdenis@simphalempin.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:48170 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753277AbYIELnC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2008 07:43:02 -0400
Content-Disposition: inline
In-Reply-To: <20080831111304.d57b9f5a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Sun, Aug 31, 2008 at 11:13:04AM -0700, Andrew Morton (akpm@linux-foundation.org) wrote:
> > When an IFF_TUN (/dev/net/tun) device has more than 1023 IPv6 neighbors, a
> > process context crash occurs. Backtrace follows:

Does this problem still exist?

> > BUG: unable to handle kernel NULL pointer dereference at 0000001d
> > IP: [<f8b375bf>] :ipv6:ip6_dst_lookup_tail+0x95/0x15a
> > *pde = 00000000
> > Oops: 0000 [#14] SMP
> > Modules linked in: ipx p8022 psnap llc p8023 i915 drm tun cpufreq_ondemand
> > binfmt_misc fuse nf_conntrack_ftp nf_conntrack_ipv6 nf_conntrack_ipv4
> > nf_conntrack ipv6 snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm_oss
> > snd_mixer_oss snd_pcm snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event
> > snd_seq snd_timer snd_seq_device snd intel_agp psmouse soundcore agpgart button
> > processor snd_page_alloc parport_pc parport iTCO_wdt evdev pcspkr dm_mirror
> > dm_log dm_snapshot dm_mod sg sr_mod cdrom e100 mii ehci_hcd uhci_hcd usbcore
> > unix
> > 
> > Pid: 9950, comm: tunload Tainted: G      D   (2.6.26.3 #8)

By whom it was tainted?

-- 
	Evgeniy Polyakov
