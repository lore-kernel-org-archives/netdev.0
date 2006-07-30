From: Kyle McMartin <kyle@parisc-linux.org>
Subject: Re: [parisc-linux] [git patches] tulip fixes from parisc-linux
Date: Sun, 30 Jul 2006 14:54:56 -0400
Message-ID: <20060730185456.GA17066@tachyon.int.mcmartin.ca>
References: <20060729225459.GA4835@athena.road.mcmartin.ca> <20060730004339.GC11975@colo.lackof.org> <20060730165607.GB4835@athena.road.mcmartin.ca> <20060730113532.4db2fcb5.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: grundler@parisc-linux.org, val_henson@linux.intel.com,
	netdev@vger.kernel.org, parisc-linux@lists.parisc-linux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stout.engsoc.carleton.ca ([134.117.69.22]:3225 "EHLO
	stout.engsoc.carleton.ca") by vger.kernel.org with ESMTP
	id S932431AbWG3Syq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 14:54:46 -0400
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060730113532.4db2fcb5.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 30, 2006 at 11:35:32AM -0700, Andrew Morton wrote:
> hm.  A couple of those patches have been futzing around in -mm for over a
> year and have been nacked by Jeff and are a regular source of grumpygrams. 
> I've been sitting on them in the pathetic hope that someone will one day
> get down and address the bugs which they fix in an acceptable fashion,
> whatever that is.
> 

Jeff/Val seemed willing to merge the fixes as they stood. parisc-linux
merged Francois' tulip workqueue patch some time ago, and have been
running with it since without issue. This defers the tulip_select_media
work to process context, and so should be less of an issue.

Cheers,
	Kyle
