From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC NET 00/02]: Secondary unicast address support
Date: Thu, 21 Jun 2007 21:13:37 +0200
Message-ID: <467ACDE1.7070907@trash.net>
References: <20070620180017.6685.70611.sendpatchset@localhost.localdomain> <m13b0lf7mr.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	davem@davemloft.net, jeff@garzik.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45761 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753097AbXFUTOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 15:14:00 -0400
In-Reply-To: <m13b0lf7mr.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> I'm trying to understand what the point of this patch is.
>
> In once sense I find the concept of filtering and listening for multiple
> mac addresses very interesting, especially if we could break out different
> streams of traffic by destination mac address into separate network devices.
> This would remove the need to any kind of ethernet tunnel and makes multiple
> network namespaces much more pleasant.
>
> However this just seems to allow a card to decode multiple mac addresses
> which in some oddball load balancing configurations may actually be
> useful, but it seems fairly limited.
>
> Do you have a specific use case you envision for this multiple mac
> functionality?
>   

Yes, please see the MACVLAN patch I posted one or two days earlier.
8021q can also make use of it and Dave mentioned some virtualization
devices want this as well.


