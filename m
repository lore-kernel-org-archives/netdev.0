From: Abhishek Gupta <abhishek@pal.ece.iisc.ernet.in>
Subject: Multiple REDs per Queue
Date: Mon, 4 Apr 2005 09:56:49 +0530 (IST)
Message-ID: <Pine.BSO.4.58.0504040940330.16180@pal.ece.iisc.ernet.in>
References: <Pine.BSO.4.58.0504011240500.6284@pal.ece.iisc.ernet.in>
 <20050402213642.GO3086@postel.suug.ch> <Pine.BSO.4.58.0504032018040.30630@pal.ece.iisc.ernet.in>
 <20050403194739.GR3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050403194739.GR3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello
Once again thanks Mr. Graf. I have changed my UDP packet generator to
Linux's pktgen which generates UDP packets at very high speed and also at 
constant rate. Things are now working quite well. Thanks for letting me
know about the bmon software. Its a great software and is helping me a 
lot in my work. I have something more to ask. The problem goes as follows:
In my project I want to use multiple REDs per queue i.e, in a queue, 
various tcps(persistent, non-persistent etc) will be operated 
with different RED parameters(min and max threshold, beta, pmax etc) 
but operate on same queue length and not on individual queue 
lengths(including average queue length). Is it possible with linux's tc 
option to have multiple REDs per queue. As far as I could able to 
understand, linux tc option provides only one RED per queue.
If it is not possible with tc option, then where I need to make changes in 
source code to achieve the forementioned set-up.
Thanks.
abhishek


=========================================================================
ABHISHEK GUPTA 
E-mail:abhishek_it_bhu@yahoo.co.in
=========================================================================

On Sun, 3 Apr 2005, Thomas Graf wrote:

> * Abhishek Gupta <Pine.BSO.4.58.0504032018040.30630@pal.ece.iisc.ernet.in> 2005-04-03 20:30
> > But the problem is still 
> > not yet solved as I tried with 1Mbit speed as the setting for link speed 
> > in the htb configuration and got about 30KBps which amounts to about 
> > 240Kbitps even though my UDP source is sending at speed of about 
> > 1MBps(8Mbps), according to RH monitor readings. 
> 
> I do not know about that "RH monitor" you are referring to, maybe it
> does not display rates correctly. (I found 3 out of 5 rate estimators
> outputing with a variance of over 10%) I can recommend you bmon [0]
> which states the variance and can be used to a resolution up to
> 1/100s given the input source provides an equal or better resolution.
> 
> > Is it possible that the problem is due to the source that I am using for 
> > UDP packets?
> 
> Very likely, especially due to the huge difference in requested and
> achieved rate you have mentioned above. I hardly think this is a
> problem related to HTB but rather some misconfiguration in your testing
> process.
> 
> [0] http://people.suug.ch/~tgr/bmon/
> 
