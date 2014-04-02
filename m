From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Wed, 2 Apr 2014 16:38:30 -0400
Message-ID: <20140402203830.GE3301@tuxdriver.com>
References: <20140326165934.GH2869@minipsycho.orion>
 <533312A3.5070600@cumulusnetworks.com>
 <20140326180356.GK2869@minipsycho.orion>
 <2D65D0C2-6BBC-4968-8400-4EB60BDF887A@cumulusnetworks.com>
 <533C1F91.6000704@greyhouse.net>
 <20140402152546.GB3596@tuxdriver.com>
 <CD1A9D96-F1E1-4AF6-B089-41AEBF7F1699@cumulusnetworks.com>
 <20140402192915.GB3301@tuxdriver.com>
 <20140402130437.24885fd8@nehalam.linuxnetplumber.net>
 <20140402202318.GC2844@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39976 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932889AbaDBUpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 16:45:52 -0400
Content-Disposition: inline
In-Reply-To: <20140402202318.GC2844@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 02, 2014 at 10:23:18PM +0200, Jiri Pirko wrote:
> Wed, Apr 02, 2014 at 10:04:37PM CEST, stephen@networkplumber.org wrote:
> >On Wed, 2 Apr 2014 15:29:15 -0400
> >"John W. Linville" <linville@tuxdriver.com> wrote:
> >
> >> I've seen the 'ethtool -S' example before and I guess it is valid.
> >> Still, is it worth the confusion of having a mostly useless/unique
> >> netdev just to reuse an ethtool ioctl?  Maybe, I guess...?
> >
> >ethtool is actually the most worthless part of the API.
> >It can't be monitored, is ioctl based but and the statistics are device
> >dependent making them useless for monitoring applications.
> 
> Has anyone actually been thinking about converting ethtool functionality
> to netlink as well? I did some time ago. Most of it should be easy (more or less)
> to do I believe.

Seems like a good idea...but only if you promise to have it primarily
accessed by a tool with a 2-letter name! :-)

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
