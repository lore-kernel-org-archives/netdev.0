From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] firewire net: Ensure checksumming in upper layer.
Date: Mon, 21 Jan 2013 00:10:29 +0900
Message-ID: <50FC08E5.6020903@linux-ipv6.org>
References: <50FBA02C.9030203@linux-ipv6.org> <20130120105058.1aee26c4@stein> <50FBC8D5.50205@linux-ipv6.org> <50FC0353.8090902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>,
	linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: stephan.gatzka@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50FC0353.8090902@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephan Gatzka wrote:
> 
>>> Indeed neither the device nor the lower drivers check protocol checksums.
>>> But the CRCs of the encapsulating 1394 packets are checked in hardware.
>>> Shall protocol checksums be verified regardless?
>>
>> Yes, because packets may come from off-link source.
>>
> 
> Hm, I can't see any off-link packets coming from fwnet_finish_incoming_packet()
> 
> So I wont verify checksums in the driver.

"Off-link source" means the source exists on the different L2
network.  In other words, source is connected via router(s).

         ethernet             firewire
 Host -------------- Router ------------ Host

--yoshfuji
