From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of IRQF_SAMPLE_RANDOM
Date: Fri, 16 May 2008 10:15:34 -0400
Message-ID: <20080516141534.GD11302@csclub.uwaterloo.ca>
References: <20080515142154.0595e475@core> <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com> <482C7B18.6060003@garzik.org> <482C7E53.3050300@hp.com> <482C8184.2030906@garzik.org> <482C8550.5000909@intel.com> <482C8D4D.3040702@garzik.org> <20080516132107.GA11304@csclub.uwaterloo.ca> <482D8EE9.10404@garzik.org> <87a5b0800805160659j1e8482efjea2fb8167f755e05@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Rick Jones <rick.jones2@hp.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Chris Peterson <cpeterso@cpeterso.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Will Newton <will.newton@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:44995 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752713AbYEPOPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 10:15:36 -0400
Content-Disposition: inline
In-Reply-To: <87a5b0800805160659j1e8482efjea2fb8167f755e05@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2008 at 02:59:03PM +0100, Will Newton wrote:
> I don't know egd that well, but from a cursory look it gets data from
> such things as w or last (wtmp) which is static on most embedded
> boxes. It also uses netstat and snmp - surely this is at least as easy
> to manipulate as interrupt timings? I'm not a cryptographer by any
> means but it looks as if it works by magic. Last changed 2002, written
> in perl. No, I don't think I'll be shipping this on any systems any
> time soon.

I will certainly keep applying a patch to the kernel to enable the
ethernet driver as a source of entropy.  I won't expect the upstream
kernel to want it, but it certainly is useful to have some source of
entropy.  Generating an ssl key or the like can take an awful long time
if you have no sources at all.

The last thing I need is another perl script eating up resources for no
good reason.

-- 
Len Sorensen
