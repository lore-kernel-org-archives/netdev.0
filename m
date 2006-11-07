From: Al Boldi <a1426z@gawab.com>
Subject: Re: ZONE_NORMAL memory exhausted by 4000 TCP sockets
Date: Tue, 7 Nov 2006 11:06:53 +0300
Message-ID: <200611071106.53975.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zhao Xiaoming wrote:
> The latest update:
>     It seems that Linux kernel memory management mechanisms including
> buddy and slab algorisms are not very efficient under my test
> conditions that tcp stack requires a lot of (hundreds of MB) packet
> buffers and release them very frequently.
>     Here is the proof. After change my kernel configuration to support
> 2/2 VM splition, LOMEM consumption reduced to 270M bytes compared with
> 640M bytes of the 1/3 kernel. All test conditions are the same and
> memory pages allocated by TCP stack are also the same, 34K ~ 38K
> pages. In other words, 'lost' memory changed from ~500M to ~130M.
> Thus, I have nothing to do but guessing the much more free pages make
> the slab/buddy algorisms more efficient and waste less memory.

I kind of agree, and always compile for a 2G/2G VM split, as this also seems 
to affect certain OOM conditions positively.

What isn't quite clear though, why is the 2G/2G VM split not the default?


Thanks!

--
Al

