From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: Re: [Bugme-new] [Bug 14450] New: [2.6.31] Network interfaces are dead with 2.6.31 (iwlagn and sky2)
Date: Wed, 4 Nov 2009 10:47:26 -0600
Message-ID: <200911040947.28054.bjorn.helgaas@hp.com>
References: <bug-14450-10286@http.bugzilla.kernel.org/> <20091103152146.5785195a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: orion.linbug@gmail.com, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	linux-acpi@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	linux-wireless@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:47970 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757350AbZKDQr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 11:47:29 -0500
In-Reply-To: <20091103152146.5785195a.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 03 November 2009 04:21:46 pm Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).

> > http://bugzilla.kernel.org/show_bug.cgi?id=14450

This looks like a duplicate of http://bugzilla.kernel.org/show_bug.cgi?id=13940

There's a patch in that bug that is upstream already:
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=15b812f1d0a5ca8f5efe7f5882f468af10682ca8

Please try booting 2.6.31 with "pci=use_crs" and report the result.

If possible, please also try booting an upstream kernel containing
the patch above (without "pci=use_crs") and report that result, too.
