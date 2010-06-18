From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [Bugme-new] [Bug 16187] New: Carrier detection failed in
	dhcpcd when link is up
Date: Fri, 18 Jun 2010 00:16:41 -0600
Message-ID: <20100618061641.GA7039@lackof.org>
References: <bug-16187-10286@https.bugzilla.kernel.org/> <20100615142418.f47e8abd.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, casteyde.christian@free.fr
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from complete.lackof.org ([198.49.126.79]:39189 "EHLO
	complete.lackof.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262Ab0FRGQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jun 2010 02:16:56 -0400
Content-Disposition: inline
In-Reply-To: <20100615142418.f47e8abd.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 15, 2010 at 02:24:18PM -0700, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).

I've resync to linus' tree (2.6.35-rc3) and reviewed the output of:
    git diff v2.6.34 drivers/net/tulip/

I don't see anything that would affect how link state
changes get reported to user space.

I'm not inclined to believe this is a tulip "bug" unless
core netdev behavior changed and tulip is not longer
doing the right thing.

hth,
grant
