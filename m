From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] tcp: fix setting csum_start in tcp_gso_segment
Date: Wed, 25 Jun 2014 10:10:52 -0400
Message-ID: <20140625141052.GA1096@redhat.com>
References: <alpine.DEB.2.02.1406242056330.29780@tomh.mtv.corp.google.com>
 <CA+55aFxyZP_jXT-bLyFjJMp4WfVZp5vFtpu+-6_qCi46xkceQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11307 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756873AbaFYOLw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2014 10:11:52 -0400
Content-Disposition: inline
In-Reply-To: <CA+55aFxyZP_jXT-bLyFjJMp4WfVZp5vFtpu+-6_qCi46xkceQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 24, 2014 at 09:17:25PM -0700, Linus Torvalds wrote:
 > On Tue, Jun 24, 2014 at 9:03 PM, Tom Herbert <therbert@google.com> wrote:
 > >
 > > It looks like a likely culprit is that SKB_GSO_CB()->csum_start is
 > > not set correctly when doing non-scatter gather. We are using
 > > offset as opposed to doffset.
 > >
 > > Reported-by: Dave Jones <davej@redhat.com>
 > 
 > DaveJ, I think you triggered this in five minutes on your box, and I
 > don't recall seeing anybody else reporting the oops (and google
 > doesn't find anything in the last month). So it's presumably somewhat
 > hw-specific. Does this fix the problem?

It's survived routing ~1GB of packets overnight, so I'd call this good.

thanks Tom.

	Dave
