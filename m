From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 0/8] partial resend: e1000 fixes and updates
Date: Thu, 18 Jan 2007 11:56:04 -0500
Message-ID: <45AFA6A4.4090503@pobox.com>
References: <20070113003650.16816.34076.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44428 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752055AbXARQ4M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 11:56:12 -0500
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20070113003650.16816.34076.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Hi,
> 
> This patch series contains exclusively fixes for e1000. Some of these patches were
> already sent in december, but didn't make it into any usptream tree yet. Most
> importantly, it addresses two issues in the recently merged msi interrupt
> handler and dynamic itr code. A performance fix and some minor cleanups are also
> added. This brings the driver up to version 7.3.20-k2.
> 
> The summary below lists all patches. Once that were previously acked are annotated
> with (*)
> 
> These patches apply against netdev-2.6 #upstream-linus commit
> 77aab8bf22042d1658d4adbca8b71779e7f2d0ff. Please pull:
> 
> git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream-linus

Sigh.  I /know/ I've told you this before, but let's review the branches 
again.  NEVER EVER use branch 'upstream-linus'.  That is for Linus only.

There are three branches you should care about:

master			Vanilla upstream Linus tree, as of my last pull
upstream-fixes		netdev fixes being sent to Linus for -rc
upstream		Everything else pending, but not yet merged

The decision tree is as follows:

* If there are no dependent e1000 changes, send patches against master 
(or torvalds/linux-2.6.git, if you prefer)
* If there are dependent e1000 changes in #upstream-fixes, send patches 
against #upstream-fixes
* If there are dependent e1000 changes in #upstream, send patches 
against #upstream

In the current tree there are no e1000 changes, so please regenerate 
your tree against vanilla linux-2.6.git and resubmit.

I ACK patches 1-8.

	Jeff




