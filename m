From: Dax Kelson <dax@gurulabs.com>
Subject: Re: thinkpad issue --No PCMCIA hotplug activity when onboard nic
	(e1000) down
Date: Mon, 27 Sep 2004 15:06:05 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096319165.4075.78.camel@mentorng.gurulabs.com>
References: <1096317629.4075.65.camel@mentorng.gurulabs.com>
	 <20040927215304.E26680@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-net@vger.kernel.org,
        netdev@oss.sgi.com, dahinds@users.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Russell King <rmk+lkml@arm.linux.org.uk>
In-Reply-To: <20040927215304.E26680@flint.arm.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-09-27 at 14:53, Russell King wrote:
> On Mon, Sep 27, 2004 at 02:40:29PM -0600, Dax Kelson wrote:
> > Myself and a co-worker have two ThinkPads bought a few months apart. The
> > two model numbers are:
> > 
> > 2373-KUU -- T42p 14" LCD
> > 2373-CXU -- T42 15" LCD
> > 
> > Both have the following onboard NIC and cardbus controller
> > 02:01.0 Ethernet controller: Intel Corp. 82540EP Gigabit Ethernet Controller (Mobile) (rev 03)
> > 02:00.0 CardBus bridge: Texas Instruments PCI4520 PC card Cardbus Controller (rev 01)
> > 02:00.1 CardBus bridge: Texas Instruments PCI4520 PC card Cardbus Controller (rev 01)
> 
> Can you also provide the output of lspci -n for the above two
> cardbus bridges please?

Sure..

# lspci -n | grep 02:00
02:00.0 Class 0607: 104c:ac46 (rev 01)
02:00.1 Class 0607: 104c:ac46 (rev 01)
