From: Shawn Starr <shawn.starr@rogers.com>
Subject: Re: [2.6.18-rc2][e1000][swsusp] - Regression - Suspend to disk and resume breaks e1000
Date: Sun, 16 Jul 2006 13:33:20 -0400
Message-ID: <200607161333.20858.shawn.starr@rogers.com>
References: <200607160509.52930.shawn.starr@rogers.com> <44BA6A4A.5090007@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp101.rog.mail.re2.yahoo.com ([206.190.36.79]:49003 "HELO
	smtp101.rog.mail.re2.yahoo.com") by vger.kernel.org with SMTP
	id S1750898AbWGPRd1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jul 2006 13:33:27 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <44BA6A4A.5090007@intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 16 July 2006 12:33, Auke Kok wrote:
> [adding netdev to the cc]
>
>
> unfortunately I didn't.
>
> e1000 has a special e1000_pci_save_state/e1000_pci_restore_state set of
> routines that save and restore the configuration space. the fact that it
> works for suspend to memory to me suggests that there is nothing wrong with
> that.
>
> I'm surprised that the t42 comes with a PCI/PCI-X e1000, which changes the
> need for this special routine, and the routine does the exact same thing as
> pci_save_state in your case. These special routines are made to handle
> PCI-E cards properly.
>
> Also there are no config_pm changes related to this in 2.6.18-rc2. Most of
> this code has been in the kernel for a few major releases afaik. This code
> worked fine before, so I don't rule out any suspend-related issues. You
> should certainly compare with 2.6.18-rc1 and make sure it was a regression,
> perhaps even bisect the e1000-related changes if you have the time, which
> is about 22 patches or so.
>
> I'll see if I can find out some more once I get back to work.
>
> Auke

The previous kernel I was using was 2.6.17 vanilla, so between this and -git 
snapshots I'll have to see where that changed.

Thanks ,
Shawn.
