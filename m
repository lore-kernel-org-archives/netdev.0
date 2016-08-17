From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH 1/2] ipaddress: Simplify vf_info parsing
Date: Wed, 17 Aug 2016 23:27:20 +0200
Message-ID: <20160817212720.GE28702@orbyte.nwl.cc>
References: <1464811430-19415-1-git-send-email-phil@nwl.cc>
 <1464811430-19415-2-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:48148 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752834AbcHQV1X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2016 17:27:23 -0400
Content-Disposition: inline
In-Reply-To: <1464811430-19415-2-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 01, 2016 at 10:03:49PM +0200, Phil Sutter wrote:
> Not sure whether I misinterpret commit 7b8179c780a1a, but it looks
> overly complicated. Instead rely upon parse_rtattr_nested() to assign
> the relevant pointer if requested rtattr fields are present.

In order to validate correctness of this patch, I compiled a kernel
which does not export IFLA_VF_SPOOFCHK and verified correct
functionality.

Is there anything else I could do in order to convince you to accept
these patches?

Thanks, Phil
