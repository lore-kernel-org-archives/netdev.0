From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next 4/8] bridge: sysfs cleanup
Date: Thu, 19 Jun 2008 18:19:45 -0700
Message-ID: <20080619181945.2b242e4d@extreme>
References: <485AFFF3.6070802@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:52913 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751059AbYFTBTr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 21:19:47 -0400
In-Reply-To: <485AFFF3.6070802@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Jun 2008 08:55:15 +0800
Wang Chen <wangchen@cn.fujitsu.com> wrote:

> When I am doing this series of patch, I notice that bridge's sysfs are
> not cleanuped after failure and bridge delete.
> 
> Here is the patch for it.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Let me look at this, I don't think it used to be a problem before the
conversion from class_device to just device model.
