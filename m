From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Tue, 17 May 2016 18:00:06 -0700
Message-ID: <CA+55aFw_JRGNo3HYP3c=3VoGw_uYBP_h2OmxOMcUGsU=L43btw@mail.gmail.com>
References: <20160517.151113.367799295750703003.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Intel Linux Wireless <linuxwifi@intel.com>,
	Linux Wireless List <linux-wireless@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160517.151113.367799295750703003.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 17, 2016 at 12:11 PM, David Miller <davem@davemloft.net> wrote:
>
> Highlights:

Lowlights:

 1) the iwlwifi driver seems to be broken

My laptop that uses the intel 7680 iwlwifi module no longer connects
to the network. It fails with a "Microcode SW error detected." and
spews out register state over and over again.

The last thing it says before falling over is:

  wlp1s0: authenticate with xx:xx:xx:xx:xx:xx
  wlp1s0: send auth to xx:xx:xx:xx:xx:xx (try 1/3)
  wlp1s0: send auth to xx:xx:xx:xx:xx:xx (try 2/3)

and then it goes all titsup.

I thought that it might be because I had downloaded one of the daily
firmware versions (it calls itself iwlwifi-7260-17.ucode, but isn't a
real release afaik - but it has worked fien for me before), but the
problem persists with the ver-16 ucode too, so that wasn't it.

I haven't bisected it, but there is absolutely nothing odd in my hardware.

I do have a 802.11ac network, which apparently not everybody does,
judging by previous bug-reports of mine..

Intel iwlwifi people: please check this out.

               Linus
