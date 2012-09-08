From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netlink: Rename pid to portid to avoid confusion
Date: Sat, 8 Sep 2012 09:54:41 -0700
Message-ID: <20120908095441.359df1d1@s6510.linuxnetplumber.net>
References: <87fw6tjb4p.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45170 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750940Ab2IHQyp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Sep 2012 12:54:45 -0400
In-Reply-To: <87fw6tjb4p.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 07 Sep 2012 23:12:54 -0700
ebiederm@xmission.com (Eric W. Biederman) wrote:

> It is a frequent mistake to confuse the netlink port identifier with a
> process identifier.  Try to reduce this confusion by renaming fields
> that hold port identifiers portid instead of pid.
> 
> I have carefully avoided changing the structures exported to
> userspace to avoid changing the userspace API.
> 
> I have successfully built an allyesconfig kernel with this change.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---

Ok. I validated that no header file used by iproute2 is affected.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
