From: Patrick McHardy <kaber@trash.net>
Subject: Re: possible double call of kfree_skb in net/llc/llc_sap.c
Date: Tue, 27 May 2008 08:16:11 +0200
Message-ID: <483BA72B.5010207@trash.net>
References: <84ee89da0805262300v747c712ayfb60ac8aa790edb7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Dmitry Petukhov <dmgenp@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43625 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752742AbYE0GQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 02:16:13 -0400
In-Reply-To: <84ee89da0805262300v747c712ayfb60ac8aa790edb7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry Petukhov wrote:
> In the file  net/llc/llc_sap.c, funcion llc_sap_state_process,
> the call to kfree_skb in the line 227 can proceed even if skb was already freed
> on line 218, or  224, or queued to the user within sock_queue_rcv_skb function.
> Obviously return statement is missing after line 225.
> 
> This problem was found by Alex Shevkov.

Could you send a patch please?
