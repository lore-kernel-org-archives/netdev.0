From: Marek Vasut <marex@denx.de>
Subject: Re: [PATCH net-next 1/1] net: fec: Fix NAPI race
Date: Tue, 16 Dec 2014 14:34:32 +0100
Message-ID: <201412161434.32400.marex@denx.de>
References: <1418725558-17287-1-git-send-email-b38611@freescale.com> <CAOMZO5D3cysOauyptcjCDM6sjK7ZEiAY==xYu-qqHbwFreoV8g@mail.gmail.com> <20141216114131.GQ11285@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Fabio Estevam <festevam@gmail.com>,
	Fugang Duan <b38611@freescale.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Estevam Fabio-R49496" <R49496@freescale.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	robert.daniels@vantagecontrols.com
To: "Russell King - ARM Linux" <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:48323 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbaLPNek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 08:34:40 -0500
In-Reply-To: <20141216114131.GQ11285@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, December 16, 2014 at 12:41:31 PM, Russell King - ARM Linux wrote:
> On Tue, Dec 16, 2014 at 09:33:53AM -0200, Fabio Estevam wrote:
> > Hi Fugang,
> > 
> > On Tue, Dec 16, 2014 at 8:25 AM, Fugang Duan <b38611@freescale.com> wrote:
> > > Do camera capture test on i.MX6q sabresd board, and save the capture
> > > data to nfs rootfs. The command is:
> > > gst-launch-1.0 -e imxv4l2src device=/dev/video1 num-buffers=2592000 !
> > > tee name=t ! queue ! imxv4l2sink sync=false t. ! queue ! vpuenc !
> > > queue ! mux. pulsesrc num-buffers=3720937 blocksize=4096 !
> > > 'audio/x-raw, rate=44100, channels=2' ! queue ! imxmp3enc !
> > > mpegaudioparse ! queue ! mux. qtmux name=mux ! filesink
> > > location=video_recording_long.mov
> > > 
> > > After about 10 hours running, there have net watchdog timeout kernel
> > > dump: ...
> > > WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:264
> > > dev_watchdog+0x2b4/0x2d8() NETDEV WATCHDOG: eth0 (fec): transmit queue
> > > 0 timed out
> > 
> > Adding more people who reported similar issues in the past.
> > 
> > Marek,
> > 
> > Does this patch solve the problem you reported at
> > http://www.spinics.net/lists/netdev/msg268167.html ?
> 
> My set of patches fixed stuff exactly like this...

I still keep your G+ post open, in case I ever manage to find free time to dive 
into it. It's be a terrible waste to let these patches go. Right now, I'm in the 
process of finishing my degree (finally) so things are just crap, apologies.

Best regards,
Marek Vasut
