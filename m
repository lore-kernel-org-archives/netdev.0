From: Terry Griffin <terryg@axian.com>
Subject: Re: odd behavior with r8169 and pcap
Date: Mon, 29 Nov 2004 16:01:09 -0800
Message-ID: <1101772869.3382.101.camel@tux.hq.axian.com>
References: <1101751909.2291.21.camel@tux.hq.axian.com>
	 <20041129210213.GA3880@electric-eye.fr.zoreil.com>
	 <1101766059.3382.57.camel@tux.hq.axian.com>
	 <20041129231800.GB3880@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041129231800.GB3880@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-11-29 at 15:18, Francois Romieu wrote:
> Terry Griffin <terryg@axian.com> :
> [...]
> 
> Ok, thanks for the info. It may sound like voodoo, but...
> 
> Could you pass acpi=off to the kernel and disable whatever acpi
> or USB option appearing in the bios ?
> 
> --
> Ueimor

It was already voodoo with pcap in the causal loop. So more
voodoo doesn't have the thrill it might have otherwise.

Passing acpi=off did the trick. Throughput is at the higher rate
with or without pcap monitoring. I did not have to change any BIOS
settings.

More info previously promised:

- Removing one of the RealTek adapters did not help.
- The problem still exists in 2.6.10-rc2 and 2.6.10-rc2-bk13.

Terry
