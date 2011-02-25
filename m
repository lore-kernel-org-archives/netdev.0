From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v4 1/2] iproute2: support listing devices by group
Date: Fri, 25 Feb 2011 12:43:45 -0800
Message-ID: <20110225124345.0d691789@nehalam>
References: <1296671021-24421-1-git-send-email-ddvlad@rosedu.org>
	<1296671021-24421-2-git-send-email-ddvlad@rosedu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Vlad Dogaru <ddvlad@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54499 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755925Ab1BYUnr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 15:43:47 -0500
In-Reply-To: <1296671021-24421-2-git-send-email-ddvlad@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  2 Feb 2011 20:23:40 +0200
Vlad Dogaru <ddvlad@rosedu.org> wrote:

> User can specify device group to list by using the group keyword:
> 
> 	ip link show group test
> 
> If no group is specified, 0 (default) is implied.
> 
> Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>

I applied this to net-next for iproute2
but INIT_NETDEV_GROUP is in a part of netdevice.h that is not exported 
(ie inside #ifdef KERNEL).



-- 
