From: Aaron Sethman <androsyn@ratbox.org>
Subject: Re: qfe problems on x86
Date: Tue, 23 Apr 2002 08:57:29 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0204230848540.7811-100000@simon.ratbox.org>
References: <20020423.050029.45364266.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020423.050029.45364266.davem@redhat.com>
List-Id: netdev.vger.kernel.org

I ended up compiling the module with a bunch of the debugging options
turned here is what while i was pinging my gateway then started ping it
from another host. Towards the end around TX<[13]> is where the problems
come up and this stop working.

Regards,

Aaron

eth0: Link has been forced up using internal transceiver at happy_meal_tcvr_read: reg=0x00 value=2100
100Mb/s, Full Duplex.
happy_meal_tcvr_read: reg=0x00 value=2100
happy_meal_interrupt: status=03000000 TXALL TX<[0]>done
happy_meal_interrupt: status=00010000 RXTOHOST RX<[0 len=60 csum=58d9]>done
happy_meal_interrupt: status=03000000 TXALL TX<[1]>done
happy_meal_interrupt: status=00010000 RXTOHOST RX<[1 len=98 csum=   0]>done
happy_meal_interrupt: status=03000000 TXALL TX<[2]>done
happy_meal_interrupt: status=00010000 RXTOHOST RX<[2 len=98 csum=   0]>done
happy_meal_interrupt: status=03000000 TXALL TX<[3]>done
happy_meal_interrupt: status=00010000 RXTOHOST RX<[3 len=98 csum=   0]>done
happy_meal_interrupt: status=03000000 TXALL TX<[4]>done
happy_meal_interrupt: status=00010000 RXTOHOST RX<[4 len=98 csum=   0]>done
happy_meal_interrupt: status=03000000 TXALL TX<[5]>done
happy_meal_interrupt: status=00010000 RXTOHOST RX<[5 len=98 csum=   0]>done
happy_meal_interrupt: status=03000000 TXALL TX<[6]>done
happy_meal_interrupt: status=00010000 RXTOHOST RX<[6 len=98 csum=   0]>done
happy_meal_interrupt: status=03000000 TXALL TX<[7]>done
happy_meal_interrupt: status=00010000 RXTOHOST RX<[7 len=98 csum=   0]>done
happy_meal_interrupt: status=03000000 TXALL TX<[8]>done
happy_meal_interrupt: status=00010000 RXTOHOST RX<[8 len=98 csum=   0]>done
happy_meal_interrupt: status=03000000 TXALL TX<[9]>done
happy_meal_interrupt: status=00010000 RXTOHOST RX<[9 len=98 csum=   0]>done
happy_meal_interrupt: status=03000000 TXALL TX<[10]>done
happy_meal_interrupt: status=00010000 RXTOHOST RX<[10 len=98 csum=   0]>done
happy_meal_interrupt: status=03000000 TXALL TX<[11]>done
happy_meal_interrupt: status=00010000 RXTOHOST RX<[11 len=98 csum=   0]>done
happy_meal_interrupt: status=03000000 TXALL TX<[12]>done
happy_meal_interrupt: status=00010000 RXTOHOST RX<[12 len=98 csum=   0]>done
happy_meal_interrupt: status=03010000 TXALL TX<[13]>RXTOHOST RX<[13 len=60 csum=b959]>done
happy_meal_interrupt: status=03000000 TXALL TX<[14]>done
happy_meal_interrupt: status=03000000 TXALL TX<[15]>done
happy_meal_interrupt: status=03000000 TXALL TX<[16]>done
happy_meal_interrupt: status=03000000 TXALL TX<[17]>done
happy_meal_interrupt: status=03000000 TXALL TX<[18]>done
happy_meal_interrupt: status=03000000 TXALL TX<[19]>done
happy_meal_interrupt: status=03000000 TXALL TX<[20]>done
happy_meal_interrupt: status=03000000 TXALL TX<[21]>done
happy_meal_interrupt: status=03000000 TXALL TX<[22]>done
happy_meal_interrupt: status=03000000 TXALL TX<[23]>done
happy_meal_interrupt: status=03000000 TXALL TX<[24]>done

