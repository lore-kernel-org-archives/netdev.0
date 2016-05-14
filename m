From: Guy Harris <guy@alum.mit.edu>
Subject: Re: What ixgbe devices support HWTSTAMP_FILTER_ALL for hardware time stamping?
Date: Sat, 14 May 2016 11:55:11 -0700
Message-ID: <42EB154F-A50F-4CB6-A8CD-06B7E61AA811@alum.mit.edu>
References: <582A121C-339D-4469-958C-9673C7E5A654@alum.mit.edu> <1463211680.2720.5.camel@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Network Development <netdev@vger.kernel.org>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from c.mail.sonic.net ([64.142.111.80]:35245 "EHLO c.mail.sonic.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752370AbcENSzO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 14:55:14 -0400
In-Reply-To: <1463211680.2720.5.camel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On May 14, 2016, at 12:41 AM, Jeff Kirsher <tarbal@gmail.com> wrote:

> Are you planning to produce a patch or are you wanting us to do the work to
> fix the issue?  Just asking so that work is not duplicated.

I'm willing to produce the patches, although

	1) I don't currently have a platform set up to test whether they compile;

	2) I don't have hardware on which to test whether they work (the person who submitted

		https://github.com/the-tcpdump-group/tcpdump/issues/393#issuecomment-218442072

	   does, although he doesn't have X550 hardware - I guess he wants hardware time stamping on an 82599EB; it sounds as if that won't work, and his patch to the driver won't give him what he wants);

	3) patches from the driver maintainers might 1) be more likely to do the right thing and 2) be more likely to be accepted.
