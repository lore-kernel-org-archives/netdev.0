From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH iproute2 1/3] vxlan: add support for collect metadata
 flag
Date: Wed, 16 Dec 2015 13:11:05 +0100
Message-ID: <1450267865.4626.22.camel@redhat.com>
References: <cover.1450193891.git.pabeni@redhat.com>
	 <c83d317f4849cbbb1b0551d450c3972c5bc73e2b.1450193891.git.pabeni@redhat.com>
	 <20151216115054.47dca715@griffin> <20151216115626.7a35b4ff@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shemming@brocade.com, netdev@vger.kernel.org,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34159 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752817AbbLPMLH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 07:11:07 -0500
In-Reply-To: <20151216115626.7a35b4ff@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-12-16 at 11:56 +0100, Jiri Benc wrote:
> On Wed, 16 Dec 2015 11:50:53 +0100, Jiri Benc wrote:
> > Also, as a related remark, please note that IFLA_VXLAN_COLLECT_METADATA
> > is mutually exclusive with many other flags. It's currently not
> > enforced correctly at the kernel level (instead, you get weird
> > behavior). I'll fix this on the kernel side but we may want to enforce
> > this on the iproute2 side, too, to get a better error message. This is
> > not to be addressed by this patch, though.
> 
> Actually, there's one thing this patch must do. Currently, vxlan
> enforces vni to be specified. This is not required for metadata based
> tunneling. It's actually not permitted.

Ok, thank you. I'll re-submit incorporating your feedback.

Cheers,

Paolo
