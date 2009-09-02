From: David Acker <dacker@roinet.com>
Subject: Re: 100Mbit ethernet performance on embedded devices
Date: Wed, 02 Sep 2009 15:35:08 -0400
Message-ID: <4A9EC8EC.4030006@roinet.com>
References: <20090819145057.GA25400@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-embedded@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Stezenbach <js@sig21.net>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <20090819145057.GA25400@sig21.net>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Stezenbach wrote:
> What I'm interested in are some numbers for similar hardware,
> to find out if my hardware and/or ethernet driver can be improved,
> or if the CPU will always be the limiting factor.
> I'd also be interested to know if hardware checksumming
> support would improve throughput noticably in such a system,
> or if it is only useful for 1Gbit and above.
> 
> Did anyone actually manage to get close to 100Mbit/sec
> with similar CPU resources?

I have a pico station, http://ubnt.com/products/picostation.php with 
Atheros MIPS 4KC @ 180MHz.  Iperf on this device gives 46.0 Mbits/sec 
sending TCP from a PC to the device and 36.2 Mbits/sec sending TCP from 
the device to a PC.  The NIC is part of the Atheros chipset so PCI is 
not involved.
-ack
