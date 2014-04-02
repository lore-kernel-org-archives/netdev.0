From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support
 of switch chip datapath
Date: Wed, 2 Apr 2014 13:04:37 -0700
Message-ID: <20140402130437.24885fd8@nehalam.linuxnetplumber.net>
References: <5332677F.2090404@cumulusnetworks.com>
	<5332B1FE.7080102@mojatatu.com>
	<53330639.8050403@cumulusnetworks.com>
	<20140326165934.GH2869@minipsycho.orion>
	<533312A3.5070600@cumulusnetworks.com>
	<20140326180356.GK2869@minipsycho.orion>
	<2D65D0C2-6BBC-4968-8400-4EB60BDF887A@cumulusnetworks.com>
	<533C1F91.6000704@greyhouse.net>
	<20140402152546.GB3596@tuxdriver.com>
	<CD1A9D96-F1E1-4AF6-B089-41AEBF7F1699@cumulusnetworks.com>
	<20140402192915.GB3301@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@cumulusnetworks.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Jiri Pirko <jiri@resnulli.us>,
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
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:50576 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932324AbaDBUEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 16:04:41 -0400
Received: by mail-pb0-f44.google.com with SMTP id rp16so684195pbb.31
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 13:04:41 -0700 (PDT)
In-Reply-To: <20140402192915.GB3301@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Apr 2014 15:29:15 -0400
"John W. Linville" <linville@tuxdriver.com> wrote:

> I've seen the 'ethtool -S' example before and I guess it is valid.
> Still, is it worth the confusion of having a mostly useless/unique
> netdev just to reuse an ethtool ioctl?  Maybe, I guess...?

ethtool is actually the most worthless part of the API.
It can't be monitored, is ioctl based but and the statistics are device
dependent making them useless for monitoring applications.
