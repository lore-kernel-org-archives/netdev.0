From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: aead api to reduce redundancy
Date: Mon, 09 Oct 2017 09:09:13 +0200
Message-ID: <1507532953.26041.5.camel@sipsolutions.net>
References: <20170926131945.3962-1-qasdfgtyuiop@gmail.com>
         <1506945898.25586.3.camel@sipsolutions.net>
         <CAMtaSwRU45ve71=H4C7cDQEHrkHg2=eMvXhYbe4HZGxsPRD+AQ@mail.gmail.com>
         (sfid-20171008_074412_021883_BA751082)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Xiang Gao <qasdfgtyuiop@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMtaSwRU45ve71=H4C7cDQEHrkHg2=eMvXhYbe4HZGxsPRD+AQ@mail.gmail.com> (sfid-20171008_074412_021883_BA751082)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2017-10-08 at 01:43 -0400, Xiang Gao wrote:
> 
> By the way, I'm still struggling on how to run unit tests. It might
> take time for me to make it run on my machine.

I can run it easily, so don't worry about it too much. Running it is of
course much appreciated, but I don't really want to go and require that
right now, it takes a long time to run.

If you do want to set it up, I suggest the vm scripts (hostap
repository in tests/hwsim/vm/ - you can use the kernel .config there as
a base to compile a kernel and then just kick it off from there, but it
can take a while to run.

> Hmm... good question. The reason is, aes_ccm.c and aes_gcm.c was
> almost exact copy of each other. But they have different copyright
> information.
> The copyright of aes_ccm.c was:
> 
> Copyright 2006, Devicescape Software, Inc.
> Copyright 2003-2004, Instant802 Networks, Inc.
> 
> and the copyright of aes_gcm.c was:
> 
> Copyright 2014-2015, Qualcomm Atheros, Inc.
> 
> I just don't know how to write the copyright for the new aead_api.c,
> so I does not put anything there.

Heh, good point. Well, I guess we can pretend it wasn't already copied
before and just "keep" both.

johannes
