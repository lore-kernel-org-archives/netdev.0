From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [PATCH] tipc: flow control should not account for sk_rcvbuf
Date: Thu, 4 Oct 2012 11:59:11 +0200
Message-ID: <506D5DEF.9050700@ericsson.com>
References: <1349342067-27586-1-git-send-email-erik.hugne@ericsson.com> <1349342493.16011.32.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jon Maloy <jon.maloy@ericsson.com>,
	"ying.xue@windriver.com" <ying.xue@windriver.com>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.ericsson.se ([193.180.251.45]:47297 "EHLO
	mailgw1.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756Ab2JDJ7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 05:59:16 -0400
In-Reply-To: <1349342493.16011.32.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> What guarantee do we have this cannot use all kernel memory ?
>
> If sk->sk_rcvbuf is not an acceptable limit here, you must use a
> different limit, but not infinity.
>
There is an implicit limit on how much data that can be buffered on each 
socket, controlled by TIPC_FLOW_CONTROL_WIN.

This limit is:
TIPC_FLOW_CONTROL_WIN * 2 * TIPC_MAX_USER_MSG_SIZE

//E
