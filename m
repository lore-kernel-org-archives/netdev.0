From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 7/8] mpls: Multicast route table change notifications
Date: Wed, 25 Feb 2015 23:21:11 -0800
Message-ID: <54EEC967.20106@cumulusnetworks.com>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org> <87fv9tvrgq.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org,
	Vivek Venkatraman <vivek@cumulusnetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:36765 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbbBZHVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 02:21:14 -0500
Received: by pdjp10 with SMTP id p10so11054813pdj.3
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 23:21:13 -0800 (PST)
In-Reply-To: <87fv9tvrgq.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/25/15, 9:19 AM, Eric W. Biederman wrote:
> Unlike IPv4 this code notifies on all cases where mpls routes
> are added or removed as that was the simplest to implement.
>
> In particular routes being removed because a network interface
> goes down or is removed are notified about.  Are there technical
> arguments for handling this differently ? Userspace developers
> don't particularly like the way IPv4 handles route removal
> on ifdown.
that is true. However, from previous emails on this topic on netdev,
there is no reason to notify these deletes to userspace thereby creating 
a notification storm
when userspace can figure this out. Which seems like a valid reason.
(Your approach resembles IPv6 which does generate these notifications 
and userspace is usually happy with this).

Thanks.
