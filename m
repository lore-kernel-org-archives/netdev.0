From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Problem using HTB
Date: Sun, 3 Apr 2005 21:47:39 +0200
Message-ID: <20050403194739.GR3086@postel.suug.ch>
References: <Pine.BSO.4.58.0504011240500.6284@pal.ece.iisc.ernet.in> <20050402213642.GO3086@postel.suug.ch> <Pine.BSO.4.58.0504032018040.30630@pal.ece.iisc.ernet.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Abhishek Gupta <abhishek@pal.ece.iisc.ernet.in>
Content-Disposition: inline
In-Reply-To: <Pine.BSO.4.58.0504032018040.30630@pal.ece.iisc.ernet.in>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Abhishek Gupta <Pine.BSO.4.58.0504032018040.30630@pal.ece.iisc.ernet.in> 2005-04-03 20:30
> But the problem is still 
> not yet solved as I tried with 1Mbit speed as the setting for link speed 
> in the htb configuration and got about 30KBps which amounts to about 
> 240Kbitps even though my UDP source is sending at speed of about 
> 1MBps(8Mbps), according to RH monitor readings. 

I do not know about that "RH monitor" you are referring to, maybe it
does not display rates correctly. (I found 3 out of 5 rate estimators
outputing with a variance of over 10%) I can recommend you bmon [0]
which states the variance and can be used to a resolution up to
1/100s given the input source provides an equal or better resolution.

> Is it possible that the problem is due to the source that I am using for 
> UDP packets?

Very likely, especially due to the huge difference in requested and
achieved rate you have mentioned above. I hardly think this is a
problem related to HTB but rather some misconfiguration in your testing
process.

[0] http://people.suug.ch/~tgr/bmon/
