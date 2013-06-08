From: Cong Wang <amwang@redhat.com>
Subject: Re: ping_group_range documentation patch (question)
Date: Sat, 08 Jun 2013 17:59:28 +0800
Message-ID: <1370685568.868.2.camel@cr0>
References: <CAGXs5wUg-WjRM2Ky2wckQdv0M7mm51KNXSFZvWUf03Jr0Q-ueQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lorenzo@google.com
To: Kevin Wilson <wkevils@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20531 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751503Ab3FHJ7l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jun 2013 05:59:41 -0400
In-Reply-To: <CAGXs5wUg-WjRM2Ky2wckQdv0M7mm51KNXSFZvWUf03Jr0Q-ueQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-07 at 15:56 +0300, Kevin Wilson wrote:
> 
> 
> Any ideas  what should I do in order  to enable ICMP sockets "for all the world"
> so any use can use them ? and shouldn't this be documented in
> Documentation/networking/ip-sysctl.tx?
> 

GID_T_MAX is the max you can set, and it is defined as:

#define GID_T_MAX (((gid_t)~0U) >> 1)

that is 2147483647, 4294967295 is larger than it, therefore you got
EINVAL.


Yes, this should be documented, patch is welcome! :)

Thanks!
