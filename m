From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 8169 driver with NetGear GA511 card.
Date: Thu, 28 Oct 2004 09:48:27 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041028074827.GA3572@electric-eye.fr.zoreil.com>
References: <41802CA8.8070900@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <41802CA8.8070900@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear <greearb@candelatech.com> :
[...]
> I tried stressing it, and it can handle about 30Mbps bi-directional
> (1514 byte pkts).  I was hoping for better...but not too bad.

There is a direction for which a 2x factor has been reported.
It does not look like a completely dysfunctional setup.

[...]
> Kernel is 2.6.9 + my networking patches, compiled for pentium-M
>   NAPI for 8169 is enabled.
> 
> hardware is nx5000 laptop
> 
> My thanks to the 8169 driver writer(s).  I will continue to debug

Many people help.

> this, and will be happy to try any suggestions for improving performance
> and/or stability of this NIC.

The r8169 in -mm and in -netdev includes some extra buzzword-compliant
features (TX csum/SG and TSO mainly). The changes are isolated in a
single patch against 2.6.9 available at:
http://www.fr.zoreil.com/people/francois/misc/20041020-2.6.9-r8169.c-test.patch

I will not claim it is as stable as vanilla 2.6.9 should be.

The frequency of requests for jumbo frames went higher lately ("Realtek
driver does it"). There is some code I need to test before it is pushed to
-mm. 

Btw:
[...]
> I recompiled w/out NAPI and no more problems, though performance is
> horrible (about 5Mbps bi-directional).

Please send the usuals 'lspci -vx' + /proc/interrupts contents during
activity + complete dmesg + short description of the generated traffic.
I will hardly dissect it before the week end but there is a problem. :o(

> If the developer/maintainer could use one of these cardbus NICs, I'm
> willing to donate one to help further development and stability.

I work with the plain PCI version of the GA 511 but I can use a laptop
for testing. Please contact me offline if you can send an adapter and
accept euro.

--
Ueimor
