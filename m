From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: 2.6.37 regression: adding main interface to a bridge breaks vlan
 interface RX
Date: Mon, 17 Jan 2011 18:17:38 +0000
Message-ID: <4D3487C2.7060506@simon.arlott.org.uk>
References: <4D32FC1C.3010905@simon.arlott.org.uk> <1295280044.6264.5.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	jesse@nicira.com, Herbert Xu <herbert@gondor.apana.org.au>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([81.2.80.65]:51416 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752331Ab1AQSRn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jan 2011 13:17:43 -0500
In-Reply-To: <1295280044.6264.5.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/01/11 16:00, Ben Hutchings wrote:
> On Sun, 2011-01-16 at 14:09 +0000, Simon Arlott wrote:
>> [    1.666706] forcedeth 0000:00:08.0: ifname eth0, PHY OUI 0x5043 @ 16, addr 00:e0:81:4d:2b:ec
>> [    1.666767] forcedeth 0000:00:08.0: highdma csum vlan pwrctl mgmt gbit lnktim msi desc-v3
>> 
>> I have eth0 and eth0.3840 which works until I add eth0 to a bridge.
>> While eth0 is in a bridge (the bridge device is up), eth0.3840 is unable
>> to receive packets. Using tcpdump on eth0 shows the packets being
>> received with a VLAN tag but they don't appear on eth0.3840. They appear
>> with the VLAN tag on the bridge interface.
> [...]
> 
> This means the behaviour is now consistent, whether or not hardware VLAN
> tag stripping is enabled.  (I previously pointed out the inconsistent
> behaviour in <http://thread.gmane.org/gmane.linux.network/149864>.)  I
> would consider this an improvement.

Shouldn't the kernel also prevent a device from being both part of a
bridge and having VLANs? Instead everything appears to work except
incoming traffic.

-- 
Simon Arlott
