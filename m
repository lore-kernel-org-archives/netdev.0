From: Noriaki TAKAMIYA <takamiya@linux-ipv6.org>
Subject: Re: [PATCH] [IPV6] fixed the size of the netlink message notified
 by inet6_rt_notify().
Date: Fri, 19 Jan 2007 01:31:08 +0900 (JST)
Message-ID: <20070119.013108.465780507.takamiya@linux-ipv6.org>
References: <20070116.140159.02303722.takamiya@po.ntts.co.jp>
	<20070117105006.GV8693@postel.suug.ch>
	<45AE1792.1010002@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from linux6.nezu.wide.ad.jp ([203.178.142.218]:57463 "EHLO
	nezu.linux-ipv6.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932446AbXARQid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jan 2007 11:38:33 -0500
To: kaber@trash.net
In-Reply-To: <45AE1792.1010002@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

>> Wed, 17 Jan 2007 13:33:22 +0100
>> [Subject: Re: [PATCH] [IPV6] fixed the size of the netlink message notified by inet6_rt_notify().]
>> Patrick McHardy <kaber@trash.net> wrote...

> Somewhat related: I have this patch for 2.6.21 to get rid of the
> BUG_ON()s.

  I think the problem is the return value of inet6_rt_notify() is less
  than expected.

--
Noriaki TAKAMIYA
