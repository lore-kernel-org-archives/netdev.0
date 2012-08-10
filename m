From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 07/14] bridge: add some comments for NETDEV_RELEASE
Date: Fri, 10 Aug 2012 10:38:06 +0800
Message-ID: <1344566286.17296.4.camel@cr0>
References: <uiuqn4l019wk5s0l9cq2w0cy.1344541199595@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40430 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751439Ab2HJCiU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2012 22:38:20 -0400
In-Reply-To: <uiuqn4l019wk5s0l9cq2w0cy.1344541199595@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-09 at 09:44 -1000, Stephen Hemminger wrote:
> If you are going to add an explanation, then I would prefer a more complete one. Something like:
> "Since more than one interface can be attached to a bridge, there still maybe an alternate path for netconsole to use; therefore there is no reason for a NETDEV_RELEASE event."

Yeah, this is better.

> 
> But my opinion it really isn't necessary to document what isn't done in the code, only what is done. The purpose of comments is to explain the wider impacts of the code.

The reason why I add it is to remind people like me who forgot the
reason behind. ;)

Thanks.
