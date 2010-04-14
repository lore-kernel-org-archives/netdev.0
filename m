From: stephen mulcahy <smulcahy@gmail.com>
Subject: Re: forcedeth driver hangs under heavy load
Date: Wed, 14 Apr 2010 15:30:41 +0100
Message-ID: <4BC5D191.9030905@gmail.com>
References: <1271160298.2098.0.camel@achroite.uk.solarflarecom.com>	 <4BC47F38.5040509@gmail.com> <1271169741.16881.437.camel@edumazet-laptop>	 <20100413.144340.138717714.davem@davemloft.net> <1271195179.16881.575.camel@edumazet-laptop> <4BC5539B.6050908@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"572201@bugs.debian.org" <572201@bugs.debian.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep17-int.chello.at ([62.179.121.37]:37893 "EHLO
	viefep17-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755464Ab0DNOax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 10:30:53 -0400
In-Reply-To: <4BC5539B.6050908@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ayaz Abdulla wrote:
> Attached fix has been submitted to netdev.

I've run my reproducer with this patch applied to be Debian 2.6.32 
kernel and so far the problem with nodes becoming unresponsive hasn't 
occurred.

NIC settings were left the default so this looks positive

root@node23:~# ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: on
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: off
large-receive-offload: off

Thanks!

-stephen
