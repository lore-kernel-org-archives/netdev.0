From: jamal <hadi@cyberus.ca>
Subject: Re: cls_u32 compile failure in current 2.6.12-rc1+BK tree
Date: 28 Mar 2005 07:24:18 -0500
Message-ID: <1112012657.1089.1013.camel@jzny.localdomain>
References: <Pine.SOC.4.61.0503272249040.5086@math.ut.ee>
	 <1111972035.1091.946.camel@jzny.localdomain>
	 <Pine.SOC.4.61.0503281017060.21333@math.ut.ee>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-bounce@oss.sgi.com>
To: Meelis Roos <mroos@linux.ee>
In-Reply-To: <Pine.SOC.4.61.0503281017060.21333@math.ut.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-03-28 at 02:18, Meelis Roos wrote:
> > For now just turn on actions under qos menu.
> 
> The help tells
> You MUST NOT turn this on if you dont have an update iproute2.
> So I did not turn it on. I have iproute 20041019-3 in Debian unstable. 
> Will something break? I'm not using QoS actively, sonly try some setups 
> sometimes.

Well, it is NOT supposed to break - but lets find out shall we? ;->

Thomas: I have been doing some thinking.
If we are going to make u32 an exception then this code should be
surrounded by #ifdef ..ACTION..
The rest of the classifiers can also follow the same scheme.
Or the rest of the classifiers can have their code in the generic stats
(and removed from within the classifiers).
Which means that the other classifiers may have to use a slightly
different function name unless you want to pass a variable to
distinguish the two cases. My time is about to become scarce, so if you
have time please create the patch.

cheers,
jamal
