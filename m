From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH net-next] ipv4/netfilter: remove unnecessary goto statement
 for error recovery
Date: Mon, 20 Aug 2012 04:43:53 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208200438530.6655@stinky-local.trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Usually it's a good practice to use goto statement for error recovery
> when initializing the module. This approach could be an overkill if:
>
>  1) there is only one fail case;
>  2) success and failure use the same return statement.
> 
> For a cleaner approach, remove the unnecessary goto statement and
> directly implement error recovery.

We have tons of similar cases. And this is much better than directly
adding rollback since it doesn't require changing unrelated code if
anything new is added to the initialization code. Additionally its
usually directly comparable to the cleanup code.

