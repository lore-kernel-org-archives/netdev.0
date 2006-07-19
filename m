From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2 drops immediately after boot
Date: Wed, 19 Jul 2006 15:16:35 -0400
Message-ID: <20060719151635.55e39018@localhost.localdomain>
References: <44BDF56E.6000202@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcclung@nebrwesleyan.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:4539 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030221AbWGSTRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 15:17:18 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <44BDF56E.6000202@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a patch to add a debugging /proc/net/sky2/ethX interface to dump
status rings. This interface will not be part of released drivers and should
not be shipped in distribution kernels. It doesn't handle things like
device renaming and is purely released as is.

http://developer.osdl.org/shemminger/prototypes/sky2-proc-debug.patch

You can use this to see if status or tx ring are hanging.
