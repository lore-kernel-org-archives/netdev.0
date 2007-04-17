From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH 2.6] WE-22 : prevent information leak on 64 bit
Date: Tue, 17 Apr 2007 14:19:00 -0700
Message-ID: <20070417211859.GB22897@bougret.hpl.hp.com>
References: <20070323003116.GC2712@bougret.hpl.hp.com> <1175508410.23438.75.camel@johannes.berg> <20070417170820.GB22372@bougret.hpl.hp.com> <20070417183442.GE8633@tuxdriver.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:54934 "EHLO
	gundega.hpl.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbXDQVTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 17:19:55 -0400
Content-Disposition: inline
In-Reply-To: <20070417183442.GE8633@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 17, 2007 at 02:34:42PM -0400, John W. Linville wrote:
> On Tue, Apr 17, 2007 at 10:08:20AM -0700, Jean Tourrilhes wrote:
> > 
> > 	First, I'm the current active maintainer of the
> > wext-over-netlink interface, and nobody bothered to even 'inform' me
> > about its removal, let alone consult with me.
> 
> Honestly, most of us thought you weren't interested.

	Please !

> This API was controversial and mostly unwelcome from the start.
> It was ridiculed as "ioctls over netlink" at the last kernel summit.

	Which is complete FUD. In that case, the whole RtNetlink can
be classified as "ioctls over netlink".

> One of the objections to having merged the API was that _if_ it were
> to gain users then we would have to carry that maintenance burden
> ad infinitum.

	More FUD. It does not add any new commands. The proof is in
the pudding, no change was needed in any driver to support it,
therefore it could not have added any burden on any compatibility
layer.

> Regards,
> 
> John

	Have fun...

	Jean
