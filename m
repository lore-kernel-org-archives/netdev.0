From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 3/7 net-2.6.25] [IPV4]: Prohibit assignment of 0.0.0.0
 as interface address.
Date: Fri, 25 Jan 2008 08:34:04 -0800
Message-ID: <20080125083404.5f3c6176@deepthought>
References: <1201269123-20378-1-git-send-email-den@openvz.org>
	<1201269123-20378-3-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:42816 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753352AbYAYQeQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2008 11:34:16 -0500
In-Reply-To: <1201269123-20378-3-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Jan 2008 16:51:59 +0300
"Denis V. Lunev" <den@openvz.org> wrote:

> I could hardly imagine why sombady needs to assign 0.0.0.0 as an interface
> address or interface destination address. The kernel will behave in a strage
> way in several places if this is possible, as ifa_local != 0 is considered
> as initialized/non-initialized state of the ifa.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
>

This is used as a way to bring device up in lots of existing documentation.
So please don't change.

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
