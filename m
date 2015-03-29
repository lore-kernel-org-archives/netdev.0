From: Richard Weinberger <richard@nod.at>
Subject: Re: [RFC PATCH 00/11] an introduction of library operating system
 for Linux (LibOS)
Date: Sun, 29 Mar 2015 18:47:45 +0200
Message-ID: <55182CB1.2090002@nod.at>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>	<551164ED.5000907@nod.at>	<m2twxacw13.wl@sfc.wide.ad.jp>	<55117565.6080002@nod.at>	<m2sicuctb2.wl@sfc.wide.ad.jp>	<55118277.5070909@nod.at>	<m2bnjhcevt.wl@sfc.wide.ad.jp>	<55133BAF.30301@nod.at> <m2r3s7ak9f.wl@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: pooka@iki.fi, linux-arch@vger.kernel.org, arnd@arndb.de,
	corbet@lwn.net, cl@linux.com, penberg@kernel.org,
	rientjes@google.com, iamjoonsoo.kim@lge.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, netdev@vger.kernel.org
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <m2r3s7ak9f.wl@sfc.wide.ad.jp>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 29.03.2015 um 17:36 schrieb Hajime Tazaki:
> 
> 
> At Sat, 28 Mar 2015 22:17:40 +0100,
> Richard Weinberger wrote:
> 
>>> Continuous testing is paramount.  Running the kernel as
>>> a lib provides an unparalleled method for testing most of
>>> the kernel.  It will improve testing capabilities
>>> dramatically,
>>> and on the flipside it will keep the libos working.
>>> Everyone wins.
>>
>> If it can be done cheap, yes. But our in-kernel tests improved over the years a lot.
>> Now have lockdep, KASan, kmemleak, etc. to find *real-world* issues and the need for stubbed testing
>> decreases.
> 
> let me take the same example I raised.
> 
> - Patchwork [net-next] xfrm6: Fix a offset value for network header in _decode_session6
> http://patchwork.ozlabs.org/patch/436351/
> 
> without stubbed testing (I didn't know this term btw), we
> can't decrease untested paths of the code.
> 
> the above bug is for Mobile IPv6, which not so many people
> are using though, but it's certainly a regression for a
> person.
> 
> testing framework with libos is based on a network
> simulator, with a slight decreased realism (but it can
> detect a real bug !), but provides a lightweight multi-node
> testing framework with a single test scenario script to
> control over the nodes.
> 
> it doesn't require heavyweight machines nor complex cabling
> for a bunch of tests.
> 
> even a framework is not cheap, I would use such a testing
> tool IF we can improve the code. plus (as you may know), it
> certainly reduces the maintenance effort once it's automated.

Don't get me wrong, I totally agree that this kind of testing is good.
But as I said before we have to keep the maintenance burden in mind.

Let's wait a bit what Arnd says. He is the Linux arch maintainer.

Thanks,
//richard
