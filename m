From: Daniele Venzano <webvenza@libero.it>
Subject: Re: SiS900 Bugreport
Date: Sat, 27 Nov 2004 19:26:54 +0100
Message-ID: <20041127182654.GC2356@gateway.milesteg.arr>
References: <1838546024.20041126141110@solidirc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: phrozen77 <phrozen77@solidirc.com>
Content-Disposition: inline
In-Reply-To: <1838546024.20041126141110@solidirc.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Nov 26, 2004 at 02:11:10PM +0100, phrozen77 wrote:
> on one of my Servers, running Gentoo with a 2.6.9-r1 kernel,
> i have an integrated SiS900 Networking Chipset(rev 90) which
> is making trouble. It is turning off networking seemingly
> "at will" and when the network is in some more or less
> "idle"-state.
> 
> The Output of dmesg | grep eth0 and in /var/log/messages is full of
> these:
> 
> Nov 25 15:37:48 $HOSTNAME eth0: Media Link Off
> Nov 25 15:37:58 $HOSTNAME eth0: Media Link On 100mbps full-duplex
> 
> Searching the whole Web now for several days, all i come up with is
> that this seemingly is a multi-distribution and even multi-kernel
> problem, but no solution :(
> 
> I tried resolving this with disabling ACPI / APM in the kernel,
> searching for patches and other methods to resolve it but sadly
> nothing did help.

Sadly I can't help you right now, recently I'm receiving more and more 
reports of 'strange things' that happen with sis900 around the world. 
There is something that goes wrong with MII detection, I've just replied
to another report that reported a non working sis900 after a reboot
cycle. It has to keep the machine powered off some time before the
sis900 restarts working.

You can send me the output of a kernel compiled eith this [1] patch, or
the output of the mii-diag program (preferred) [2]. That says to me what
hardware you have, and I can see if it is already supported or not.

I'm planning a rework of the sis900 code, to integrate it better with
kernel interfaces and clean it up, so perhaps things will get better
with time.

[1] http://teg.homeunix.org/download/kpatches/sis900-list-phy-ids.diff
[2] http://www.scyld.com/ethercard_diag.html

Thanks, bye.
-- 
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org
