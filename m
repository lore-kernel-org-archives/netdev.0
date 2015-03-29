From: Antti Kantee <pooka@iki.fi>
Subject: Re: [RFC PATCH 00/11] an introduction of library operating system
 for Linux (LibOS)
Date: Sun, 29 Mar 2015 16:59:58 +0000
Message-ID: <55182F8E.3020606@iki.fi>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>	<551164ED.5000907@nod.at>	<m2twxacw13.wl@sfc.wide.ad.jp>	<55117565.6080002@nod.at>	<m2sicuctb2.wl@sfc.wide.ad.jp>	<55118277.5070909@nod.at>	<m2bnjhcevt.wl@sfc.wide.ad.jp>	<55133BAF.30301@nod.at>	<m <55152137.20405@nod.at> <55157495.3050208@iki.fi> <55171A74.1000707@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arch@vger.kernel.org, arnd@arndb.de, corbet@lwn.net,
	cl@linux.com, penberg@kernel.org, rientjes@google.com,
	iamjoonsoo.kim@lge.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org
To: Richard Weinberger <richard@nod.at>,
	Hajime Tazaki <tazaki@wide.ad.jp>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <55171A74.1000707@nod.at>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28/03/15 21:17, Richard Weinberger wrote:
> Am 27.03.2015 um 16:17 schrieb Antti Kantee:
>> Let me try to offer some insight.  I've been working on something similar in mainline NetBSD for almost 8 years now, so in addition to ideas popping into my head I've also tested
>> them out in the real world.  I do think that all operating systems should be structured to support a lib mode, and hopefully integrating Hajime's work into Linux will get on the
>> right track.
>
> IMHO it depends on the maintenance burden.
> Linux source changes magnitudes faster than NetBSD's.

I can understand why you're worried about maintenance burden -- believe 
me, I've heard all the excuses before, starting all the way back from 
"it's impossible".  Let's dissect your concern.

There's a reason I wrote in my original mail: "Figuring out how to make 
the libos as close to zero-maintenance as possible is indeed the trick". 
  It took me a few weeks to make things work in my version, but it took 
four years to figure out how to make things as maintainable as I could 
figure out how to make them.  The good news is that the results of those 
four years are more or less generic and independent of OS.

The source may change an order of magnitude faster in Linux, but Linux 
also has several orders of magnitude more resources.  Even if you do not 
believe that available resources are relevant in the equation, you can 
still take the data from NetBSD, multiply the maintenance burden with 
any Stetson-Harrison constant you see fit, and have your expected Linux 
maintenance burden value.

Mind game: what if I were to assert that the maintenance burden of 
application compatibility is too high on Linux compared to NetBSD due to 
the high rate of change?  I think everyone would rush to tell me that 
I'm wrong...

So why not just evaluate Hajime et al's work for its functional merits 
and immediate benefits, and see how maintenance burden plays out by 
collecting actual data on it.

   - antti
