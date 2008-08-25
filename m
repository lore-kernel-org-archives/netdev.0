From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: CONFIG_KMOD breakage in next kernel
Date: Mon, 25 Aug 2008 10:13:58 +1000
Message-ID: <200808251013.58975.rusty@rustcorp.com.au>
References: <s5h3akzwtki.wl%tiwai@suse.de> <1219256165.3502.10.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Takashi Iwai <tiwai@suse.de>, linux-next@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	video4linux-list@redhat.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1219256165.3502.10.camel@johannes.berg>
Content-Disposition: inline
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 21 August 2008 04:16:05 Johannes Berg wrote:
> Hi,
>
> > I found that CONFIG_KMOD was already removed in linux-next tree.
> > This seems to result in many breakages.  For example, I cannot mount a
> > FAT device automatically because of failure of automatic loading of
> > nls modules.
>
> This is odd. I had posted a long series of patches removing all of the
> users I had found (similar grep like the one you used), see
> http://lkml.org/lkml/2008/7/9/150 for the whole thread.
>
>
> For some reason, only seven of those eleven patches ended up in the
> kernel, you had taken the alsa one and Rusty posted only six of them.

OK, not quite sure what happened.  I'll grab the rest and push them into 
tomorrow's linux-next.

For today, I'll pull out the CONFIG_KMOD removal.

Thanks,
Rusty.
