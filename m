From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [BUG][2.6.5 final][e100/ee100pro] NETDEV_WATCHDOG Timeout -Related
 to i2c interface?
Date: Sun, 11 Apr 2004 17:01:58 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <4079B246.4070107@pobox.com>
References: <000001c42000$dd6e78f0$0200080a@panic>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: 'Len Brown' <len.brown@intel.com>, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Shawn Starr <shawn.starr@rogers.com>
In-Reply-To: <000001c42000$dd6e78f0$0200080a@panic>
List-Id: netdev.vger.kernel.org

Shawn Starr wrote:
> Ok, this is strange, I put in an external 10/100 PRO S Adaptor, and im not
> getting anymore eth0 timeouts, I would only get eth0 timeouts on the ONBOARD
> nic if I enabled the lm80 sensor driver.. I don't know what to say, the
> onboard nic would work fine without lm80 being loaded?
> 
> Is there some sort of race condition that the onboard 10/100 PRO is doing ?

If i2c is killing the network, sounds like it's diddling something on 
the motherboard it shouldn't...

	Jeff
