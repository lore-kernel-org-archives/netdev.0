From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC 1/4] kevent: core files.
Date: Sat, 29 Jul 2006 19:48:17 +0400
Message-ID: <20060729154817.GB25926@2ka.mipt.ru>
References: <20060724.231708.01289489.davem@davemloft.net> <44C91192.4090303@oracle.com> <20060727200655.GA4586@2ka.mipt.ru> <44C930D5.9020704@oracle.com> <20060728052312.GB11210@2ka.mipt.ru> <44CA586C.4010205@oracle.com> <20060728184445.GA10797@2ka.mipt.ru> <44CA613F.9080806@oracle.com> <44CAD81A.9060401@redhat.com> <1154147562.2451.30.camel@entropy>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Ulrich Drepper <drepper@redhat.com>,
	Zach Brown <zach.brown@oracle.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:29156 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751097AbWG2Psr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 11:48:47 -0400
To: Nicholas Miell <nmiell@comcast.net>
Content-Disposition: inline
In-Reply-To: <1154147562.2451.30.camel@entropy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2006 at 09:32:42PM -0700, Nicholas Miell (nmiell@comcast.net) wrote:
> Speaking of API design choices, I saw your OLS paper and was wondering
> if you were familiar with the Solaris port APIs* and, if so, you could
> please comment on how your proposed event channels are different/better.

As far as it concerns kevents - userspace "ports" are just usual users
of kevents, like timer notifications. Add another syscall to "complete"
requested kevents and you get exactly Solaris ports.
It is fairly simple to implement on top of kevents, I just do not see
immediate benefits from that.

> -- 
> Nicholas Miell <nmiell@comcast.net>

-- 
	Evgeniy Polyakov
