From: Dave Hudson <linux-kernel@blueteddy.net>
Subject: Re: time for TCP ECN defaulting to on?
Date: Tue, 04 Nov 2008 16:16:03 +0000
Message-ID: <49107543.5080207@blueteddy.net>
References: <6278d2220811040632u7a36d68ekad5de517fd0671bb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev <netdev@vger.kernel.org>,
	Linux Networking <linux-net@vger.kernel.org>
To: Daniel J Blueman <daniel.blueman@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <6278d2220811040632u7a36d68ekad5de517fd0671bb@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel J Blueman wrote:
> Is it time to enable TCP ECN per default and get the benefits, since
> router support has been around and known-about for really considerable
> time?
> 
> Perhaps it should be a question of enabling it, and educating people
> to disable it if they run into issues, since we'll probably be in the
> same situation in 5 years...and it'll be some time before these
> kernels hit devices/servers anyway.
> 
> Daniel

Unfortunately I think you'll find there are sufficiently large numbers 
of broken SOHO routers out there that if you try this you'll cause a lot 
of problems.  The problems range from no connectivity to in a few 
extreme cases routers actually crashing or behaving in very 
unpredictable ways.  Here's one summary that got presented to the IETF 
about 18 months ago:

http://www.ietf.org/proceedings/07mar/slides/tsvarea-3/sld6.htm

When a clueless end-user gets a Linux-enabled netbook that crashes their 
router while their existing Vista or XP systems appear to work just fine 
then the Linux network stack will get the blame for being buggy, not the 
router :-(


Regards,
Dave


