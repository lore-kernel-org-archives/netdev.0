From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH iproute2] vxlan: add ipv6 support
Date: Fri, 19 Apr 2013 22:20:12 +0800
Message-ID: <1366381212.5117.23.camel@cr0>
References: <1366175423-27310-1-git-send-email-amwang@redhat.com>
	 <1366175423-27310-7-git-send-email-amwang@redhat.com>
	 <20130418155703.251298c3@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51260 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030421Ab3DSOUV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 10:20:21 -0400
In-Reply-To: <20130418155703.251298c3@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-18 at 15:57 -0700, Stephen Hemminger wrote:
> On Wed, 17 Apr 2013 13:10:23 +0800
> Cong Wang <amwang@redhat.com> wrote:
> 
> > +			if (!inet_pton(AF_INET, *argv, &gaddr)) {
> > +				if (!inet_pton(AF_INET6, *argv, &gaddr6)) {
> > +					fprintf(stderr, "Invalid address \"%s\"\n", *argv);
> > +					return -1;
> > +				} else if (!IN6_IS_ADDR_MULTICAST(&gaddr6))
> > +					invarg("invald group address", *argv);
> > +			} else if (!IN_MULTICAST(ntohl(gaddr)))
> > +					invarg("invald group address", *argv);
> 
> Maybe using getaddrinfo would be better to allow symbolic names as well?

Yes, but I don't think many people use symbolic name for a multicast
group?

Thanks.
