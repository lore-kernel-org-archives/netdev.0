From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v4 3/5] vxlan: add ipv6 support
Date: Wed, 17 Apr 2013 21:18:12 +0800
Message-ID: <1366204692.700.8.camel@cr0>
References: <1366175423-27310-1-git-send-email-amwang@redhat.com>
	 <1366175423-27310-4-git-send-email-amwang@redhat.com>
	 <CAF1J0HOYVCe-0MVE6-mxyjEOaEAWNR16Wpv7+CF6rxbEgBQ3GA@mail.gmail.com>
	 <1366192640.700.3.camel@cr0>
	 <CAF1J0HNu9i_N2AtxvKL=edsVbZpZCsJL0mh2HEfF2G28CYcHYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29166 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965955Ab3DQNS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Apr 2013 09:18:56 -0400
In-Reply-To: <CAF1J0HNu9i_N2AtxvKL=edsVbZpZCsJL0mh2HEfF2G28CYcHYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-17 at 13:36 +0300, Mike Rapoport wrote:
> Well, I think that the address comparison helpers,
> vxlan_nla_{get,put}_addr, vxlan_newlink and vxlan_fill_info can be
> left with run-time checks only. Maybe some other places as well.
> Removing the ifdefs will increase compile time for kernels configured
> with IPV6=n, and may have certain run-time performance impact for such
> kernels. On the other hand, less ifdefs means better readability :).

In theory, yes; in this case, I don't think having these ifdefs harms
the readability.
