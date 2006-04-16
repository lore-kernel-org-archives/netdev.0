From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 locks up in 2.6.16.5
Date: Sun, 16 Apr 2006 16:43:54 +0200
Message-ID: <20060416144354.GA11433@electric-eye.fr.zoreil.com>
References: <20060415204716.GA1755@jupiter.toms.net> <20060416005821.GA9821@electric-eye.fr.zoreil.com> <20060416134201.GA2681@jupiter.toms.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:59343 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1750730AbWDPOpc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Apr 2006 10:45:32 -0400
To: "Thomas A. Oehser" <tom@toms.net>
Content-Disposition: inline
In-Reply-To: <20060416134201.GA2681@jupiter.toms.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas A. Oehser <tom@toms.net> :
[...]
> I tested with everything turned off (no SMP, no swap, no
> USB, no firewire, no iptables, no lmsensors, flat 1G memory,
> etc. etc. etc.) except the bare minimum (LSI new Megaraid for the
> SCSI and SATA raid arrays, both of which use the same driver, EXT3,
> VGA console, keyboard, mouse).  Also, with everything static and
> no modules.

Ok, it really looks like a genuine bug.

[...]
> Changing _nothing_ other than replacing EEPRO100 with R8169 and
> vice versa causes it to work perfectly or fail abominably... the
> machine always had both nics physically connected, so it was just
> the software change of one driver or the other as eth0.
> 
> There was no dmesg output.

Then the Rx part of the driver is more screwed than the Tx one.

I'll welcome a complete dmesg after you have recovered through
ifconfig down/up though.

[...]
> Note, it will be a day or few before I can retest with ethtool etc.,
> I have to do my taxes today.

No problem. One more question: have you enabled NAPI ? If not, you
should.

-- 
Ueimor
