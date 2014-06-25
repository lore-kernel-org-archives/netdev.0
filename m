From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch net-next v2 1/2] rtnetlink: allow to register ops
 without ops->setup set
Date: Wed, 25 Jun 2014 11:45:00 -0700
Message-ID: <20140625114500.7c09874e@haswell>
References: <1403715503-9059-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, pshelar@nicira.com,
	cwang@twopensource.com, nicolas.dichtel@6wind.com,
	ebiederm@xmission.com, david@gibson.dropbear.id.au,
	sfeldma@cumulusnetworks.com, sucheta.chakraborty@qlogic.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:62715 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752912AbaFYSpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 14:45:05 -0400
Received: by mail-pb0-f47.google.com with SMTP id up15so2045951pbc.34
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 11:45:04 -0700 (PDT)
In-Reply-To: <1403715503-9059-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Jun 2014 18:58:22 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> So far, it is assumed that ops->setup is filled up. But there might be
> case that ops might make sense even without ->setup. In that case,
> forbid to newlink and dellink.
> 
> This allows to register simple rtnl link ops containing only ->kind.
> That allows consistent way of passing device kind (either device-kind or
> slave-kind) to userspace.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Can't we fix these kind of devices to all create/delete. At least
allow delete.
