From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [RFD] Layering: Use-Case Composers (was: DRBD - what is it,
 anyways? [compare with e.g. NBD + MD raid])
Date: Sun, 12 Aug 2007 19:03:44 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0708121901290.28963@fbirervta.pbzchgretzou.qr>
References: <200708121335.17267.a1426z@gawab.com>
 <Pine.LNX.4.64.0708121325170.28963@fbirervta.pbzchgretzou.qr>
 <Pine.LNX.4.64.0708120933210.19502@asgard.lang.hm>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Al Boldi <a1426z@gawab.com>, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	linux-raid@vger.kernel.org
To: david@lang.hm
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0708120933210.19502@asgard.lang.hm>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Aug 12 2007 09:39, david@lang.hm wrote:
>
> now, I am not an expert on either option, but three are a couple things that I
> would question about the DRDB+MD option
>
> 1. when the remote machine is down, how does MD deal with it for reads and
> writes?

I suppose it kicks the drive and you'd have to re-add it by hand unless done by
a cronjob.

> 2. MD over local drive will alternate reads between mirrors (or so I've been
> told), doing so over the network is wrong.

Certainly. In which case you set "write_mostly" (or even write_only, not sure
of its name) on the raid component that is nbd.

> 3. when writing, will MD wait for the network I/O to get the data saved on the
> backup before returning from the syscall? or can it sync the data out lazily

Can't answer this one - ask Neil :)




	Jan
-- 
