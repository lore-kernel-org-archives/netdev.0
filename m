From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: "cfg80211: fix SME connect" breaks iwl3945
Date: Mon, 21 Sep 2009 21:20:35 +0200
Message-ID: <20090921192035.GG23126@kernel.dk>
References: <20090921190150.GC23126@kernel.dk> <200909212114.06642.chunkeey@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	johannes@sipsolutions.net, netdev@vger.kernel.org
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753378AbZIUTUg@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200909212114.06642.chunkeey@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 21 2009, Christian Lamparter wrote:
> On Monday 21 September 2009 21:01:50 Jens Axboe wrote:
> > Since the latest net pull that contains our above commit
> > (bbac31f4c0339f6c51afbd0edfb4959df9b53fa9 in tree), my iwl3945 based x60
> > laptop doesn't want to connect to my access point at all. Reverting this
> > commit makes it work.
> > 
> > Let me know if you need more info.
> 
> Can you try "[PATCH] cfg80211: don't overwrite privacy setting" 
> from [1]?
> 
> [1] http://marc.info/?l=linux-wireless&m=125323296617306&w=2

Seems to bring the network back as well, it associates fine and gets a
dhcp address.

-- 
Jens Axboe
