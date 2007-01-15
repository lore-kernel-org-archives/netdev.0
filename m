From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [patch 0/6] sky2 driver update (v1.11)
Date: Mon, 15 Jan 2007 10:21:49 -0800
Message-ID: <20070115102149.1ce12188@freekitty>
References: <20061220210632.183204605@osdl.org>
	<459197B8.6010403@pobox.com>
	<20070101103644.02544c46@freekitty>
	<20070102191015.GA5758@dose.home.local>
	<20070113130329.GA9124@dose.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34139 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751281AbXAOSW2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jan 2007 13:22:28 -0500
To: Tino Keitel <tino.keitel@tikei.de>
In-Reply-To: <20070113130329.GA9124@dose.home.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 13 Jan 2007 14:03:29 +0100
Tino Keitel <tino.keitel@tikei.de> wrote:

> On Tue, Jan 02, 2007 at 20:10:15 +0100, Tino Keitel wrote:
> 
> [...]
> 
> > Btw., I just built 2.6.20-rc3 with patches 4 and 5 and wake on LAN now
> > works. Thanks for your work.
> 
> Hi,
> 
> I had some failures during resume from suspend with 2.6.20-rc3 and
> -rc4. I enabled pm_trace and it looks like the sky2 driver is the
> culprit:
> 
> hash matches drivers/base/power/resume.c:56
> hash matches device 0000:01:00.0
> 
> $ lspci | grep 01:00.0
> 01:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053
> PCI-E Gigabit Ethernet Controller (rev 22)
> 
> I removed the patches and had no resume failure so far.
> 
> Regards,
> Tino
> 

What kind of failures, did the system just not come up?
Did you have WOL enabled or not?

The new code checks for pci_ errors on resume and it could
be that the errors were always there.

-- 
Stephen Hemminger <shemminger@osdl.org>
