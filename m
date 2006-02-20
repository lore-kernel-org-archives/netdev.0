From: David Vrabel <dvrabel@cantab.net>
Subject: Re: [RFC] [PATCH 1/2] Driver to remember ethernet MAC values: maclist
Date: Mon, 20 Feb 2006 12:16:43 +0000
Message-ID: <43F9B32B.3090203@cantab.net>
References: <20060220010113.GA19309@deprecation.cyrius.com>	<20060220014735.GD4971@stusta.de> <20060220030146.11f418dc@inspiron>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, Martin Michlmayr <tbm@cyrius.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	John Bowler <jbowler@acm.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964916AbWBTMQz@vger.kernel.org>
To: Alessandro Zummo <alessandro.zummo@towertech.it>
In-Reply-To: <20060220030146.11f418dc@inspiron>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alessandro Zummo wrote:
> On Mon, 20 Feb 2006 02:47:35 +0100
> Adrian Bunk <bunk@stusta.de> wrote:
> 
> 
>>>Some Ethernet hardware implementations have no built-in storage for
>>>allocated MAC values - an example is the Intel IXP420 chip which has
>>>support for Ethernet but no defined way of storing allocated MAC values.
>>>With such hardware different board level implementations store the
>>>allocated MAC (or MACs) in different ways.  Rather than put board level
>>>code

For those not familar with the IXP4xx, the Ethernet drivers are
proprietary and given that there are no other proposed users of this
maclist code there's no need for it in the kernel at this time.

>>Silly question:
>>
>>Why can't this be implemented in user space using the SIOCSIFHWADDR 
>>ioctl?

I'm with Adrian on this -- it's a job for userspace.  The storage of the
MAC address isn't something that's necessarily board specific anyway but
could depend on which bootloader is used and/or the bootloader version.

>  Because sometimes you need to have networking available
>  well before userspace.

In the specific case of the IXP4xx, you presumably have some userspace
available because you've just loaded the NPE firmware from it, yes?

David Vrabel
