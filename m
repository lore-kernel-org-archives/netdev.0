From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: 4.3-rc3 Regression: NFS access stall by commit 6ae459bdaaee
Date: Mon, 28 Sep 2015 17:35:04 -0700
Message-ID: <CALnjE+rpcayxdyXwkDAqJeBgJUTOGACoGEKZRq=GhE+RDuF0OQ@mail.gmail.com>
References: <s5ha8s6bscn.wl-tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Trond Myklebust <trond.myklebust@primarydata.com>,
	Anupam Chanda <achanda@vmware.com>,
	Tom Herbert <tom@herbertland.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Takashi Iwai <tiwai@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <s5ha8s6bscn.wl-tiwai@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 28, 2015 at 6:12 AM, Takashi Iwai <tiwai@suse.de> wrote:
> [I resent this since the previous mail didn't go out properly, as it
>  seems; apologies if you already read it, please disregard]
>
> Hi,
>
> I noticed that NFS access from my workstation slowed down drastically,
> almost stalls, with the fresh 4.3-rc3.  There are no particular kernel
> errors / warnings.
>
> Then I performed git section, and it leaded to the commit:
> 6ae459bdaaeebc632b16e54dcbabb490c6931d61
>     skbuff: Fix skb checksum flag on skb pull
>
> Reverting this commit from 4.3-rc3 fixed the issue indeed.
>
> Could you take a look at this?  I added Trond to Cc in case he might
> already know of it.
>
I send out fix for similar issue. Can you try the posted patch.
https://patchwork.ozlabs.org/patch/523632/
