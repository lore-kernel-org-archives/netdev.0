From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: time for TCP ECN defaulting to on?
Date: Wed, 5 Nov 2008 23:20:25 +0100 (CET)
Message-ID: <alpine.DEB.1.10.0811052316210.10993@uplift.swm.pp.se>
References: <6278d2220811040632u7a36d68ekad5de517fd0671bb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev <netdev@vger.kernel.org>,
	Linux Networking <linux-net@vger.kernel.org>
To: Daniel J Blueman <daniel.blueman@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755973AbYKEWUq@vger.kernel.org>
In-Reply-To: <6278d2220811040632u7a36d68ekad5de517fd0671bb@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 4 Nov 2008, Daniel J Blueman wrote:

> Is it time to enable TCP ECN per default and get the benefits, since 
> router support has been around and known-about for really considerable 
> time?

I think enabling ECN by default is a bad idea.

Looking at the largest core router vendor out there:

http://www.cisco.com/en/US/docs/ios/12_2t/12_2t8/feature/guide/ftwrdecn.html#wp1031751

ECN has to actually be turned on in the routers along the way, it's not 
default behaviour. No ISP I know of does this, but I can do a poll of 
other ISP engineers in case more information is wanted.

So the upside of enabling it is minimal (I'd gladly see data proving the 
opposite) and the downside is a lot of trouble with lots of older devices 
which behave badly when ECN is enabled.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
