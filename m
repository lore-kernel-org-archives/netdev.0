From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: 8139 resetting problem
Date: Mon, 19 Jan 2004 09:30:09 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <400BE9F1.9020100@pobox.com>
References: <Pine.GSO.4.44.0401191248200.8408-100000@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Meelis Roos <mroos@linux.ee>
In-Reply-To: <Pine.GSO.4.44.0401191248200.8408-100000@math.ut.ee>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Meelis Roos wrote:
> I helped to debug a problem with a onboard realtek (8100B/8139D) NIC in
> a laptop (Clevo/KAPOK sceleton, sold as Ordi D27 in Estonia). The
> problem is that sometimes Linux does not initialize the NIC well enough
> so that I get messages about Tx timed out and DHCP not getting
> addresses. DHCP server sees requests but the laptop never sees the
> answers.
> 
> Trial and error showed that the problem occurs only when doing hibernate
> from Windows XP Pro and then (instead of bringing up Windows) booting
> into Linux. Even soft reboot (or halt from Linux) doesn't cure it. Going
> back into Windows and doing shutdown or restart cures it.
> 
> This happened with different versions of Linux, 2.4.18 Debian, 2.6.0
> Debian, custom 2.6.0 and Knoppix (whatever version the newest Knoppix
> uses).
> 
> 8139too and rtl8139 drivers in 2.4.18 behaved the same.
> 
> Is there anything that the 8139too driver could do to fully reset the
> card on startup?


This is unrelated to 8139too.  8139too completely resets the NIC hardware.

When the machine is in this state, the NIC simply isn't receiving 
interrupts.  The problem is "higher up", and cannot be solved at the NIC 
driver level...  i.e. ACPI or BIOS or somesuch.

	Jeff
