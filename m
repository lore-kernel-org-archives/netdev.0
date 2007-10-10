From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH][NETNS] Make ifindex generation per-namespace
Date: Wed, 10 Oct 2007 13:51:50 -0600
Message-ID: <m1wstukasp.fsf@ebiederm.dsl.xmission.com>
References: <470B71CD.3000706@openvz.org>
	<m1przoxk1v.fsf@ebiederm.dsl.xmission.com>
	<1192041243.4770.8.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:51735 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755670AbXJJTxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 15:53:09 -0400
In-Reply-To: <1192041243.4770.8.camel@johannes.berg> (Johannes Berg's message
	of "Wed, 10 Oct 2007 20:34:03 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg <johannes@sipsolutions.net> writes:

> On Tue, 2007-10-09 at 11:41 -0600, Eric W. Biederman wrote:
>
>> So please hold off on this until the kernel has been audited and
>> we have removed all of the uses of ifindex that assume ifindex is
>> global, that we can find.
>
> I certainly have this assumption in the wireless code (cfg80211). How
> would I go about removing it? Are netlink sockets per-namespace so I can
> use the namespace of the netlink socket to look up a netdev?

Yes.  Netlink sockets are per-namespace and you can use the namespace
of a netlink socket to look up a netdev.

Eric
