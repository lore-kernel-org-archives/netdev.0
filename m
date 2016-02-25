From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH net-next V2 00/16] net: fec: cleanup and fixes
Date: Thu, 25 Feb 2016 08:57:15 -0700
Message-ID: <56CF245B.8050504@boundarydevices.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
 <87oab518wo.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com,
	fabio.estevam@freescale.com, andrew@lunn.ch,
	stillcompiling@gmail.com, linux@arm.linux.org.uk, arnd@arndb.de,
	sergei.shtylyov@cogentembedded.com, laci@boundarydevices.com,
	johannes@sipsolutions.net, l.stach@pengutronix.de,
	shawnguo@kernel.org, linux-arm-kernel@lists.infradead.org,
	tremyfr@gmail.com
To: Holger Schurig <holgerschurig@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33039 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932407AbcBYP5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 10:57:18 -0500
Received: by mail-pf0-f175.google.com with SMTP id q63so34789844pfb.0
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 07:57:18 -0800 (PST)
In-Reply-To: <87oab518wo.fsf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/25/2016 1:39 AM, Holger Schurig wrote:
> Hi Troy,
> 
> what is the general aim of your patches?  Stability?  Speed?  Cleanup?
> 

1. Stability
2. performance
3. easier to read
4. more debug info


The 2nd goal is very hard to measure. It seems function alignment changes swamp
most any other improvements. I think that if the same measurement that I did were done
with a different compiler, you would see different patches increased/decreased
the BPS. But at least the overall trend on the patch set is positive. And
each individual patch has been tested. I would like someone to test on a machine
with 3 queues though.


If you have a more accurate way to measure performance, please let me know.
Also, if you know why freescale's bsp has so much better performance
that would be a very welcome patch.

Troy
