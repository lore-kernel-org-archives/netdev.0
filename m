From: "Shawn Starr" <shawn.starr@rogers.com>
Subject: RE: [BUG][2.6.5 final][e100/ee100pro] NETDEV_WATCHDOG Timeout -Related to i2c interface?
Date: Tue, 13 Apr 2004 01:16:33 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <000001c42116$7d00fb70$0200080a@panic>
References: <4079B246.4070107@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Len Brown'" <len.brown@intel.com>, <linux-kernel@vger.kernel.org>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>
In-Reply-To: <4079B246.4070107@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Might be, I have since not had any issues with timeouts. Though, I don't
know where it is doing this. It is an IBM machine so some things are
proprietary.

-----Original Message-----
From: Jeff Garzik 
Sent: Sunday, April 11, 2004 05:02 PM
To: Shawn Starr
Cc: 'Len Brown'; linux-kernel@; netdev@
Subject: Re: [BUG][2.6.5 final][e100/ee100pro] NETDEV_WATCHDOG Timeout
-Related to i2c interface?


Shawn Starr wrote:
> Ok, this is strange, I put in an external 10/100 PRO S Adaptor, and im 
> not getting anymore eth0 timeouts, I would only get eth0 timeouts on 
> the ONBOARD nic if I enabled the lm80 sensor driver.. I don't know 
> what to say, the onboard nic would work fine without lm80 being 
> loaded?
> 
> Is there some sort of race condition that the onboard 10/100 PRO is 
> doing ?

If i2c is killing the network, sounds like it's diddling something on 
the motherboard it shouldn't...

	Jeff
