From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] vxlan: don't allow overwrite of config src addr
Date: Thu, 23 Feb 2017 17:03:29 +0100
Message-ID: <20170223170329.1623bf53@griffin>
References: <1487611528-11468-1-git-send-email-brussell@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Brian Russell <brussell@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49866 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751098AbdBWQDc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 11:03:32 -0500
In-Reply-To: <1487611528-11468-1-git-send-email-brussell@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Feb 2017 17:25:28 +0000, Brian Russell wrote:
> When using IPv6 transport and a default dst, a pointer to the configured
> source address is passed into the route lookup. If no source address is
> configured, then the value is overwritten.
> 
> IPv6 route lookup ignores egress ifindex match if the source adress is set,
> so if egress ifindex match is desired, the source address must be passed
> as any. The overwrite breaks this for subsequent lookups.
> 
> Avoid this by copying the configured address to an existing stack variable
> and pass a pointer to that instead.

Seems there were another patches applied between the time you created
the patch and sent it and it doesn't apply.

Feel free to add to v2:

Acked-by: Jiri Benc <jbenc@redhat.com>

 Jiri
