From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: FYI - TCP/IP thin stream latency
Date: Fri, 24 Oct 2008 07:59:38 -0700
Message-ID: <20081024075938.0dddb745@extreme>
References: <20081016095518.749ae6e9@speedy>
	<20081022.221410.139436406.davem@davemloft.net>
	<Pine.LNX.4.64.0810231516220.7072@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, doug.leith@nuim.ie,
	Netdev <netdev@vger.kernel.org>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44894 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751246AbYJXO7o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Oct 2008 10:59:44 -0400
In-Reply-To: <Pine.LNX.4.64.0810231516220.7072@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was  reading "Removing Exponential Backoff from TCP" by Mondal and Kusmznovic at Northwesetern
in ACM CCR. The paper tries to show that nothing breaks by getting rid of backoff. Interestingly,
FreeBSD already doesn't do backoff until after 5th retry.
