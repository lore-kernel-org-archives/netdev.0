From: "John Smith" <multisyncfe991@hotmail.com>
Subject: Can I do a regular read to simulate prefetch instruction?
Date: Mon, 30 Jan 2006 10:25:34 -0700
Message-ID: <BAY108-DAV12766C7B1A084C00C833FE93090@phx.gbl>
References: <20060124225919.GC12566@suse.de> <20060124232142.GB6174@inferi.kami.home> <20060125090240.GA12651@suse.de> <20060125121125.GH5465@suse.de> <4807377b0601251137r7621216byc47b03a3c634557c@mail.gmail.com> <4807377b0601251628k4227dad0ld731f2c25c211b91@mail.gmail.com> <BAY108-DAV111F6EF46F6682FEECCC1593140@phx.gbl> <4807377b0601271404w6dbfcff6s4de1c3f785dded9f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964830AbWA3RZg@vger.kernel.org>
To: <netdev@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I find out some network card drivers (e.g. e1000 driver) use prefetch 
instruction
to reduce memory access latency and speed up data operation. My question is:
Support we want to pre-read a skb buffer into the cache, what is the 
difference
between the following two methods, i.e. what is the different when using 
prefetch
and using a regular read opertation?
1. use prefetch instruction to stimulate a pre-fetch of the skb address,
    e.g. prefetch(skb);
2. use an assignment statement to stimulate a pre-fetch of the skb address,
    e.g. skb1 = skb;

I was told the data will be prefetched into a so-called prefetching queue 
only by
using prefetching instruction? Is this true?

Thanks,

John
