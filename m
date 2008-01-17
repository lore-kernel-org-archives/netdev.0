From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFT] sky2: wake-on-lan configuration issues
Date: Thu, 17 Jan 2008 15:22:46 -0800
Message-ID: <20080117152246.3ae65e24.akpm@linux-foundation.org>
References: <bug-9721-10286@http.bugzilla.kernel.org/>
	<478A743C.9050405@yahoo.de>
	<20080113125708.070b4843.akpm@linux-foundation.org>
	<200801132227.59229.rjw@sisk.pl>
	<478A965E.8070306@yahoo.de>
	<20080114101439.72304b92@deepthought>
	<478BCE98.5030709@yahoo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, rjw@sisk.pl,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: supersud501 <supersud501@yahoo.de>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <478BCE98.5030709@yahoo.de>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 Jan 2008 22:05:28 +0100
supersud501 <supersud501@yahoo.de> wrote:

> 
> 
> Stephen Hemminger wrote:
> > Please test this patch against Linus's current (approx 2.6.24-rc7-git5).
> > Ignore Andrew's premature reversion attempt...
> > 
> > This patch disables config mode access after clearing PCI settings.
> > 
>
> ...
> 
> yes, that did it! just tested it (current linus git tree with patched 
> sky with above patch), everything is clean now (dmesg output) and wol 
> works even with the commit ac93a3946b676025fa55356180e8321639744b31
> 
> so it the bug is fixed without the need to revert 
> ac93a3946b676025fa55356180e8321639744b31.

Are we putting this into 2.6.24?
