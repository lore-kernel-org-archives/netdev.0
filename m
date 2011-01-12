From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v2 2/2] netlink: support setting devgroup parameters
Date: Wed, 12 Jan 2011 10:44:02 -0500
Message-ID: <1294847042.2129.7.camel@mojatatu>
References: <1294763724-9927-1-git-send-email-ddvlad@rosedu.org>
	 <1294763724-9927-3-git-send-email-ddvlad@rosedu.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Octavian Purdila <opurdila@ixiacom.com>
To: Vlad Dogaru <ddvlad@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:55455 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020Ab1ALPoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 10:44:05 -0500
Received: by qyk12 with SMTP id 12so806005qyk.19
        for <netdev@vger.kernel.org>; Wed, 12 Jan 2011 07:44:05 -0800 (PST)
In-Reply-To: <1294763724-9927-3-git-send-email-ddvlad@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-01-11 at 18:35 +0200, Vlad Dogaru wrote:
> If a rtnetlink request specifies a negative or zero ifindex and has no
> interface name attribute, but has a group attribute, then the chenges
> are made to all the interfaces belonging to the specified group.
> 
> Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>

Looks good. Please just do some basic tests like setting a few
interfaces to the same group, changing their MTU and setting admin
up then down. If it works add my ACKed-by on both patches.
The only thing that will still generate a lot of noise is the netlink
events that will be generated afterwards for each change on a netdev in
a group i.e a single netlink message..

Maybe we could batch those in a future patch

cheers,
jamal

