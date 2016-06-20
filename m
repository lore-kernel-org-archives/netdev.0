From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [alsa-devel] [very-RFC 0/8] TSN driver for the kernel
Date: Mon, 20 Jun 2016 14:18:38 +0200
Message-ID: <20160620121838.GA5257@localhost.localdomain>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <20160613114713.GA9544@localhost.localdomain>
 <20160613195136.GC2441@netboy>
 <20160614121844.54a125a5@lxorguk.ukuu.org.uk>
 <5760C84C.40408@sakamocchi.jp>
 <20160615080602.GA13555@localhost.localdomain>
 <5764DA85.3050801@sakamocchi.jp>
 <20160618224549.GF32724@icarus.home.austad.us>
 <9a5abd48-4da3-945d-53c9-b6d37010ab0d@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Henrik Austad <henrik@austad.us>,
	Takashi Sakamoto <o-takashi@sakamocchi.jp>,
	alsa-devel@alsa-project.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@linaro.org>,
	linux-media@vger.kernel.org
To: Pierre-Louis Bossart <pierre-louis.bossart@linux.intel.com>
Return-path: <linux-media-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <9a5abd48-4da3-945d-53c9-b6d37010ab0d@linux.intel.com>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 20, 2016 at 01:08:27PM +0200, Pierre-Louis Bossart wrote:
> The ALSA API provides support for 'audio' timestamps (playback/capture rate
> defined by audio subsystem) and 'system' timestamps (typically linked to
> TSC/ART) with one option to take synchronized timestamps should the hardware
> support them.

Thanks for the info.  I just skimmed Documentation/sound/alsa/timestamping.txt.

That is fairly new, only since v4.1.  Are then any apps in the wild
that I can look at?  AFAICT, OpenAVB, gstreamer, etc, don't use the
new API.

> The intent was that the 'audio' timestamps are translated to a shared time
> reference managed in userspace by gPTP, which in turn would define if
> (adaptive) audio sample rate conversion is needed. There is no support at
> the moment for a 'play_at' function in ALSA, only means to control a
> feedback loop.

Documentation/sound/alsa/timestamping.txt says:

  If supported in hardware, the absolute link time could also be used
  to define a precise start time (patches WIP)

Two questions:

1. Where are the patches?  (If some are coming, I would appreciate
   being on CC!)

2. Can you mention specific HW that would support this?


Thanks,
Richard
