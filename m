From: Alex Romosan <romosan@sycorax.lbl.gov>
Subject: Re: 2.6.20-rc1 sky2 problems (regression?)
Date: Thu, 14 Dec 2006 15:08:00 -0800
Message-ID: <87fybiaxf3.fsf@sycorax.lbl.gov>
References: <87psammchi.fsf@sycorax.lbl.gov>
	<20061214133023.0b266d8e@freekitty> <87odq6azel.fsf@sycorax.lbl.gov>
	<20061214144734.03300fa6@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sycorax.lbl.gov ([128.3.5.196]:4306 "EHLO sycorax.lbl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751730AbWLNXIE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 18:08:04 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061214144734.03300fa6@freekitty> (message from Stephen
	Hemminger on Thu, 14 Dec 2006 14:47:34 -0800)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> writes:

> Another useful bit of information is the statistics (ethtool -S
> eth0). When there were flow control bugs, they would show up as
> count of 1.
>
> Are you doing jumbo frames (MTU > 1500)?

i just did 'ethtool -S eth0' (the card is still working fine) and i
don't think there are any jumbo frames. anyway, this is the output:

NIC statistics:
     tx_bytes: 2697577533
     rx_bytes: 503104106
     tx_broadcast: 18
     rx_broadcast: 4068
     tx_multicast: 0
     rx_multicast: 416
     tx_unicast: 2276028
     rx_unicast: 1359009
     tx_mac_pause: 0
     rx_mac_pause: 0
     collisions: 0
     late_collision: 0
     aborted: 0
     single_collisions: 0
     multi_collisions: 0
     rx_short: 0
     rx_runt: 0
     rx_64_byte_packets: 713826
     rx_65_to_127_byte_packets: 271861
     rx_128_to_255_byte_packets: 57307
     rx_256_to_511_byte_packets: 25689
     rx_512_to_1023_byte_packets: 28502
     rx_1024_to_1518_byte_packets: 266308
     rx_1518_to_max_byte_packets: 0
     rx_too_long: 0
     rx_fifo_overflow: 0
     rx_jabber: 0
     rx_fcs_error: 0
     tx_64_byte_packets: 174188
     tx_65_to_127_byte_packets: 225242
     tx_128_to_255_byte_packets: 44294
     tx_256_to_511_byte_packets: 24475
     tx_512_to_1023_byte_packets: 80147
     tx_1024_to_1518_byte_packets: 1727700
     tx_1519_to_max_byte_packets: 0
     tx_fifo_underrun: 0

--alex--

-- 
| I believe the moment is at hand when, by a paranoiac and active |
|  advance of the mind, it will be possible (simultaneously with  |
|  automatism and other passive states) to systematize confusion  |
|  and thus to help to discredit completely the world of reality. |
