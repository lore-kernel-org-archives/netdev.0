From: jamal <hadi@cyberus.ca>
Subject: Re: [Routing] Performance Comparison between 2.6 and 2.4 kernel
Date: 10 Sep 2004 22:11:34 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1094868693.1041.86.camel@jzny.localdomain>
References: <20040911005245.61679.qmail@web40007.mail.yahoo.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Song Wang <wsonguci@yahoo.com>
In-Reply-To: <20040911005245.61679.qmail@web40007.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


What mips board is this? NAPI based?
I would say that you should get higher numbers with 2.6.x.
Are you running any sort of apps that need gettimeofday?
I have certainly seen higher numbers on 2.6 vs 2.4 starting at some
point where Andis gettimeofday patch went in - but this was on x86.

cheers,
jamal

On Fri, 2004-09-10 at 20:52, Song Wang wrote:
> Hi,
> 
> I'm looking for the network packet routing
> performance comparison between the latest 2.4
> and 2.6 kernel.
> 
> I did some initial testing on my mips-based router.
> 2.6 kernel (2.6.8.1) performed way below 2.4 kernel
> (2.4.17). It sucks. Turning on preemption on 2.6 
> kernel even makes routing performance worse.
> 
> Anybody did a comprehensive study on the routing
> performance for 2.6 and 2.4 kernel?
> 
> Thanks.
> 
> 
> 		
> __________________________________
> Do you Yahoo!?
> Y! Messenger - Communicate in real time. Download now. 
> http://messenger.yahoo.com
> 
> 
