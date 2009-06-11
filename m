From: Martin Fuzzey <mfuzzey@gmail.com>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver configuration.
Date: Thu, 11 Jun 2009 08:47:32 +0200
Message-ID: <4A30A884.9000508@gmail.com>
References: <20090610173243.17262.91308.stgit@srv002.fuzzey.net> <1244685768.4616.22.camel@deadeye>
Reply-To: mfuzzey@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nico@cam.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:39086 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827AbZFKGrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 02:47:33 -0400
Received: by ewy6 with SMTP id 6so1713026ewy.37
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2009 23:47:34 -0700 (PDT)
In-Reply-To: <1244685768.4616.22.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Who needs this feature?  Why not use ethtool in an initramfs?
>
>   
> Forcing speed and duplex is occasionally needed to work around a link
> partner that doesn't implement autonegotiation correctly.  I don't see
> that it should ever be needed in platform configuration.  If the driver
> doesn't detect the MAC/PHY capabilities correctly then the driver should
> be fixed.  Overriding the settings once will not prevent an unsupported
> mode being selected later.
>
>   
To summarize the recent points I made in the smc91x: forcing speed thread :

1) Setting up and maintaining an initramfs can increase the complexity
for embedded systems - it's another image file to build, distribute,
update to bootloader etc.

2) While I of course agree that broken drivers should be fixed, what
about broken hardware?
I currently have this situation on one of my boards - 100Mbps doesn't
work due to electrical issues (bad routing).
This board is already in the wild - if it is fixed one day it will be a
new hardware revision and the code will have to cope with both.
Sure the "right" way is to fix the hardware but that's not always
economically or logistically possible.
I suspect such situations are not uncommon in the embedded world.


Martin

