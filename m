From: Otto Sabart <osabart@redhat.com>
Subject: Re: [BUG] net: performance regression on ixgbe (Intel 82599EB
 10-Gigabit NIC)
Date: Mon, 7 Dec 2015 12:28:37 +0100
Message-ID: <20151207112837.GA14417@redhat.com>
References: <20151203162627.GA8989@redhat.com>
 <566078AA.5040804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jirka Hladky <jhladky@redhat.com>,
	Adam Okuliar <aokuliar@redhat.com>,
	Kamil Kolakowski <kkolakow@redhat.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58412 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755337AbbLGL2j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2015 06:28:39 -0500
Content-Disposition: inline
In-Reply-To: <566078AA.5040804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi Ota,
> 
> It looks like there were a few changes that went through that could be
> causing the regression.  The most obvious one that jumps out at me is commit
> 72bfd32d2f84 ("ixgbe: disable LRO by default").  As such one thing you might
> try doing is turning on LRO support via ethtool -k to see if that is the
> issue you are seeing.
> 

Hi Alex,
enabling LRO resolved the problem.

Thank you!

Ota
