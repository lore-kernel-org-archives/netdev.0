From: Abhishek Gupta <abhishek@pal.ece.iisc.ernet.in>
Subject: Re: Problem using HTB
Date: Sun, 3 Apr 2005 20:30:19 +0530 (IST)
Message-ID: <Pine.BSO.4.58.0504032018040.30630@pal.ece.iisc.ernet.in>
References: <Pine.BSO.4.58.0504011240500.6284@pal.ece.iisc.ernet.in>
 <20050402213642.GO3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050402213642.GO3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello
Thanks Mr. Graf for replying. Ya, I do was making mistake by assuming KBps 
as Kbit per second. Actually, I got confused with notations used in the 
Linux's RH monitor which I used for the speed measurements. But the problem is still 
not yet solved as I tried with 1Mbit speed as the setting for link speed 
in the htb configuration and got about 30KBps which amounts to about 
240Kbitps even though my UDP source is sending at speed of about 
1MBps(8Mbps), according to RH monitor readings. 
Is it possible that the problem is due to the source that I am using for 
UDP packets?
abhishek



=========================================================================
ABHISHEK GUPTA 
E-mail:abhishek_it_bhu@yahoo.co.in
=========================================================================

On Sat, 2 Apr 2005, Thomas Graf wrote:

> * Abhishek Gupta <Pine.BSO.4.58.0504011240500.6284@pal.ece.iisc.ernet.in> 2005-04-01 15:10
> > tc class add dev $DEV0 parent 2: classid 2:1 htb rate 100kbit burst 100 \
> >    ceil 100kbit
> > [...]
> > I have configured for 100kbps, I am getting only 12kbps as the link speed.
> 
> Before I look into this, are you aware of 1kbps=8kbit?
> 
