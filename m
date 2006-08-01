From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [DSCAPE] rate_control needs some form of reference counting
Date: Tue, 1 Aug 2006 16:10:23 +0200
Message-ID: <20060801161023.1e66d844@griffin.suse.cz>
References: <20060729215645.GE1464@riddly.domek.prywatny>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:392 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751624AbWHAOK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 10:10:27 -0400
To: Karol Lewandowski <kl@jasmine.eu.org>
In-Reply-To: <20060729215645.GE1464@riddly.domek.prywatny>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 29 Jul 2006 23:56:45 +0200, Karol Lewandowski wrote:
> I'm getting reproductible oops when removing rt2500pci module
> (which uses devicescape ieee802.11 stack):

Thanks for the report and nice description how to reproduce the problem.

The fix is not easy. In fact, it's as hard as to fix it by implementing
a feature that allows to use different rate control algorithm for each
device. Given the fact the problem doesn't occur in normal conditions,
it's a low priority for me (unless there is a volunteer to fix it). It
needs to be fixed before d80211 is merged, though (sigh).

>   # modprobe rt2500pci
> 
> Loading module: rt2500pci - CVS (N/A) by http://rt2x00.serialmonkey.com.
> ACPI: PCI Interrupt 0000:03:00.0[A] -> GSI 21 (level, low) -> IRQ 18
> wmaster0: Failed to select rate control algorithm
> wmaster0: Failed to initialize rate control algorithm

I suppose you don't have automatic loading of modules enabled, right?

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
