From: Daniel Drake <dsd@gentoo.org>
Subject: Re: Wireless: One small step towards a more perfect union...?
Date: Wed, 11 Jan 2006 22:28:42 +0000
Message-ID: <43C5869A.5080107@gentoo.org>
References: <20060106042218.GA18974@havoc.gtf.org> <20060111020534.GA22285@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932326AbWAKW25@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060111020534.GA22285@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> If you are the maintainer of an out-of-tree driver or other component
> (e.g. softmac), please let me hear from you (publicly or privately).
> I want to be sure to identify all the major stakeholders.  I would
> also like to hear your plans for getting your code into the tree... :-)

Thanks for stepping up for this role - I'm sure it will help the 
situation improve. Here's some info about an out-of-tree driver for you:

ZD1211.

These are USB 2.0 wireless adapters, there are about 20 available on the 
market, all branded differently.

There is a GPL driver available from ZyDAS (the manufacturer) but, well, 
you really don't want to see it. There have been projects come and go 
(zd1211.sf.net, zd1211.ath.cx) which try to make the ZyDAS driver more 
workable, but they restrict themselves to small unobtrusive patches, 
leaving the code still in a horrific state, not at all suited for kernel 
inclusion.

ZyDAS also made the device specs available to us, however they are 
somewhat inaccurate, almost as if they were written about another device 
altogether.

Myself and two others have recently started rewriting the driver:

http://zd1211.ath.cx/wiki/RoadmapForKernelInclusion

We're in very early stages but progress should be fairly quick once we 
have 'deciphered' more of the junk in the vendor driver.

Right now we will be using the ieee80211 wireless stack, for the simple 
reason that this is what is included in the kernel, and our top priority 
is inclusion ASAP.

FWIW, my opinion is that the devicescape code should be broken down and 
used to extend the existing stack, no matter how 'good' it is. The way 
it has been developed (i.e. totally outside of the ieee80211 stack) is 
somewhat insulting to our development process.

Daniel
