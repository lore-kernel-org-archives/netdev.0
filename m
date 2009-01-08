From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] Make possible speeds known to ethtool
Date: Thu, 08 Jan 2009 11:11:57 -0800
Message-ID: <49664FFD.1010608@hp.com>
References: <200901080203.SAA19103@tardy.cup.hp.com>	<1231384446.2677.32.camel@hashbaz.i.decadent.org.uk> <49656F01.3090603@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:15209 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753574AbZAHTMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 14:12:00 -0500
In-Reply-To: <49656F01.3090603@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Ben Hutchings wrote:
>> The vetting of speeds is kind of silly.  Given that speed is established
>> as being a number of Mbit/s (hence the need for speed_hi), why not
>> remove the warning and the checks for known values and report it as
>> such?
> 
> 
> I'm ok with that route.  Historically it made sense, but AFAICS the 
> driver _must_ verify the speed anyway, so removing the limitation in the 
> userspace tool seems reasonable.
> 
> The next release of ethtool is coming in about 4 weeks, and we can 
> definitely get something like this in there.

I have a simple patch which does just that ready to post, but will 
point-out that removing the checks entirely will result in the speed 
being reported as 65535 (without Unknown) for an interface with its 
cable disconnected.  This however is is based only on "testing" on a 
2.6.24-22-generic (hardy) kernel with 7.3.20-k2-NAPI of the e1000 driver 
driving an Intel 82566MM (rev 03).

rick jones
