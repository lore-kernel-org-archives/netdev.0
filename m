From: "Kevin P. Fleming" <kpfleming@cox.net>
Subject: How to begin debugging ACPI/network driver interrupt problem?
Date: Wed, 09 Jul 2003 10:34:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F0C520E.2080809@cox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: acpi-support@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've got a system here using an MSI KT266-based motherboard that's 
been running 2.5.X successfully for months now. However, 2.5.73/74 
have introduced a problem that (so far) I have only been able to cure 
by either not compiling in ACPI or using acpi=off on the kernel 
command line.

The system three NICs:

eth0 is a National Semiconductor DP83815
eth1 is a National Semiconductor DP83820
eth2 is a Lite-On 82C168

All three NICs work fine. However, on the newer kernels, with ACPI 
compiled in, during initialization of eth0 the kernel generates "IRQ 
17 and nobody cared!" messages and disables IRQ 17, which causes eth0 
to be useless :-)

With older kernels, or ACPI not turned on, eth0 still gets assigned 
IRQ 17, and works just fine. IRQ 17 is not shared with any other devices.

I don't think I can handle the additional message traffic of these two 
mailing lists, so I haven't subscribed... If anyone can suggest a 
course of action for how to debug this problem, please cc me on any 
responses.
