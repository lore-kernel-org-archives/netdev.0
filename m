From: Flavio Leitner <fbl@sysclose.org>
Subject: Re: [PATCH net] netlink: don't send unknown nsid
Date: Wed, 7 Jun 2017 15:40:36 -0300
Message-ID: <20170607183746.GD2658@x240.lan>
References: <4942f9fe-625b-bb97-7b45-4a1e8bf69b1b@6wind.com>
 <1496304007-1962-1-git-send-email-nicolas.dichtel@6wind.com>
 <20170601170246.GF2673@x240.lan>
 <75fccaea-0ebe-1a2a-27d7-ad30fd99f41d@6wind.com>
 <20170601224454.GG2673@x240.lan>
 <58321cd0-6c7f-d4d8-628f-2c124d71ef82@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-of-o52.zoho.com ([135.84.80.217]:21492 "EHLO
        sender-of-o52.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752012AbdFGSnr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 14:43:47 -0400
Content-Disposition: inline
In-Reply-To: <58321cd0-6c7f-d4d8-628f-2c124d71ef82@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 05, 2017 at 10:40:24AM +0200, Nicolas Dichtel wrote:
> > Let me ask this instead: How do you think userspace should behave when
> > netnsid allocation fails?
> > 
> There is two ways to assign a nsid:
>  - manually with netlink ('ip netns set'). In this case, the error is reported
>    to userspace via netlink.

OK.

>  - automatically when a x-netns interface is created. The link-nsid is also
>    reported to userspace. If the allocation failed, NETNSA_NSID_NOT_ASSIGNED is
>    reported. And if you were able to create this x-netns interface, it means
>    that you have access to this peer netns, thus you can try to assign the nsid
>    manually.

Does that prevent the interface to be created?

> So, in both cases, userland knows that something went wrong.
> Do you have another scenario in mind?

Let's say the app is restarted, or another monitoring app is executed
with enough perms.  How will it identify the error condition?

-- 
Flavio
