From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather thand80211-specificqdisc
Date: Fri, 3 Nov 2006 14:39:20 -0500
Message-ID: <20061103193906.GB3286@tuxdriver.com>
References: <C86180A8C204554D8A3323D8F6B0A29F018B5FAE@dhost002-46.dex002.intermedia.net> <C86180A8C204554D8A3323D8F6B0A29F018B5FB0@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Stephen Hemminger <shemminger@osdl.org>,
	Christoph Hellwig <hch@infradead.org>,
	James Ketrenos <jketreno@linux.intel.com>,
	Jeff Garzik <jeff@garzik.org>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:45329 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1753501AbWKCToD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Nov 2006 14:44:03 -0500
To: Simon Barber <simon@devicescape.com>
Content-Disposition: inline
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F018B5FB0@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 03, 2006 at 11:29:33AM -0800, Simon Barber wrote:
> I should elaborate - if 802.11 is made into a real protocol - then raw
> packet capture works correctly on the master device. (raw sockets opened
> on the device see all frames before they are passed to the protocol).
> This is the right way to go.

There is some merit to this idea.  Then we could attach IBSS, WDS,
STA, or AP sub-interfaces (with or without ethernet encapsulation) in
a manner similar to how VLAN sub-interfaces are attached to ethernet
devices today.

Of course, I seem to remember ranting against that model a few
months ago.  I'll just wave my hands and call it pragmatism... :-)

John
-- 
John W. Linville
linville@tuxdriver.com
