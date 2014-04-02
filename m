From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Wed, 2 Apr 2014 22:23:18 +0200
Message-ID: <20140402202318.GC2844@minipsycho.orion>
References: <53330639.8050403@cumulusnetworks.com>
 <20140326165934.GH2869@minipsycho.orion>
 <533312A3.5070600@cumulusnetworks.com>
 <20140326180356.GK2869@minipsycho.orion>
 <2D65D0C2-6BBC-4968-8400-4EB60BDF887A@cumulusnetworks.com>
 <533C1F91.6000704@greyhouse.net>
 <20140402152546.GB3596@tuxdriver.com>
 <CD1A9D96-F1E1-4AF6-B089-41AEBF7F1699@cumulusnetworks.com>
 <20140402192915.GB3301@tuxdriver.com>
 <20140402130437.24885fd8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
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
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:47923 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758918AbaDBUXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 16:23:22 -0400
Received: by mail-wi0-f178.google.com with SMTP id bs8so1257163wib.17
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 13:23:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140402130437.24885fd8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 02, 2014 at 10:04:37PM CEST, stephen@networkplumber.org wrote:
>On Wed, 2 Apr 2014 15:29:15 -0400
>"John W. Linville" <linville@tuxdriver.com> wrote:
>
>> I've seen the 'ethtool -S' example before and I guess it is valid.
>> Still, is it worth the confusion of having a mostly useless/unique
>> netdev just to reuse an ethtool ioctl?  Maybe, I guess...?
>
>ethtool is actually the most worthless part of the API.
>It can't be monitored, is ioctl based but and the statistics are device
>dependent making them useless for monitoring applications.

Has anyone actually been thinking about converting ethtool functionality
to netlink as well? I did some time ago. Most of it should be easy (more or less)
to do I believe.
