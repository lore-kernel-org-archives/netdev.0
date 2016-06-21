From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH v2 2/7] Use C99 style initializers everywhere
Date: Tue, 21 Jun 2016 19:17:31 +0200
Message-ID: <20160621171731.GF19797@orbyte.nwl.cc>
References: <1466525921-15738-1-git-send-email-phil@nwl.cc>
 <1466525921-15738-3-git-send-email-phil@nwl.cc>
 <726e5c7d-f23b-dbf0-c1d4-721ef3d15d5b@cumulusnetworks.com>
 <20160621170333.GD19797@orbyte.nwl.cc>
 <92a1938e-523f-533f-27c9-7ec881737472@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>, netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:38484 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752517AbcFURRs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2016 13:17:48 -0400
Content-Disposition: inline
In-Reply-To: <92a1938e-523f-533f-27c9-7ec881737472@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 21, 2016 at 11:13:11AM -0600, David Ahern wrote:
> On 6/21/16 11:03 AM, Phil Sutter wrote:
> >> I downloaded CentOS 5 and 6. iproute2 fails to compile on CentOS 5.11;
> >> ip command builds on 6.8 but with a flurry of redefinition errors
> >> (BUILD_BUG_ON), but fails at tc.
> >
> > What's the exact error message please? Maybe some incompatibility in
> > kernel headers? Although that shouldn't be ...
[...]
>      CC       tc_bpf.o
> tc_bpf.c:41:26: error: linux/if_alg.h: No such file or directory

Ah! Looks like this header is missing in iproute2's copy of kernel
headers.

Stephen, would you import the missing one?

Thanks, Phil
