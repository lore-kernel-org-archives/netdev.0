From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [PATCH] tipc: flow control should not account for sk_rcvbuf
Date: Thu, 4 Oct 2012 14:12:20 +0200
Message-ID: <506D7D24.3070601@ericsson.com>
References: <1349342067-27586-1-git-send-email-erik.hugne@ericsson.com>  <1349342493.16011.32.camel@edumazet-glaptop>  <506D5DEF.9050700@ericsson.com> <1349346360.16011.36.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jon Maloy <jon.maloy@ericsson.com>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:54507 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756004Ab2JDM10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 08:27:26 -0400
In-Reply-To: <1349346360.16011.36.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> And this limit is tested _before_ queueing to backlog if socket is owned
> by the user ?
>
> You'll have to demonstrate this in the changelog.
>
> Again, I dont think this patch is safe, we need an explicit limit.
You're right Eric..

Another way of solving it is to increase the default sk_rcvbuf size to
(TIPC_FLOW_CONTROL_WIN * 2 * TIPC_MAX_USER_MSG_SIZE)
at socket creation.

Do you think that would be acceptable?
