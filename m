From: "Frank Ch. Eigler" <fche@elastic.org>
Subject: Re: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Sun, 5 Feb 2012 07:53:25 -0500
Message-ID: <20120205125325.GA31578@elastic.org>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com>
 <20120120.135028.1359677274445012541.davem@davemloft.net>
 <65795E11DBF1E645A09CEC7EAEE94B9CB8D3EA7B@USINDEVS02.corp.hds.com>
 <20120204142823.GA7000@neilslaptop.think-freely.org>
 <20120204155807.GA2657@nuttenaction>
 <20120204200937.GA2670@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	Satoru Moriya <satoru.moriya@hds.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"stephen.hemminger@vyatta.com" <stephen.hemminger@vyatta.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Seiji Aguchi <seiji.aguchi@hds.com>, fche@sourceware.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elastic.org ([69.20.226.105]:59657 "EHLO elastic.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751758Ab2BENIt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Feb 2012 08:08:49 -0500
Content-Disposition: inline
In-Reply-To: <20120204200937.GA2670@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi -

On Sat, Feb 04, 2012 at 03:09:37PM -0500, Neil Horman wrote:
> [...]

> Systemtap is fine for development.  Lots of application/product
> vendors really don't like it.  On top of the difficult to use
> aspect

(Just curious, what difficulty-to-use aspect have you more recently
come across?)

> it requires that debugging stabs info be kept with the kernel, which
> is a real pain, especially if you're running on a stable kernel.
> [...]

You probably mean when running on an unstable kernel, no?  Installing
debuginfo for a stable kernel is a one-time event.  It also enables
"perf probe" and crash(8) and other tools.  Plus, with systemtap,
there are two separate network-remoting mechanisms (--use-server
compilation and --remote execution) that make local debuginfo
unnecessary.

Anyway, a reasonable way to go may be to prototype in stap whatever
hard-coded kernel module y'all envision finally doing this work.

- FChE
