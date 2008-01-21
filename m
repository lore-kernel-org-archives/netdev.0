From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/3][NET] gen_estimator: faster gen_kill_estimator
Date: Mon, 21 Jan 2008 11:56:07 +0100
Message-ID: <20080121105607.GE1789@ff.dom.local>
References: <20080120234659.GA2691@ami.dom.local> <20080121.023515.256390630.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, slavon@bigtelecom.ru, kaber@trash.net,
	hadi@cyberus.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.190]:36865 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758531AbYAUKtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 05:49:36 -0500
Received: by mu-out-0910.google.com with SMTP id i10so6896347mue.5
        for <netdev@vger.kernel.org>; Mon, 21 Jan 2008 02:49:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080121.023515.256390630.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 21, 2008 at 02:35:15AM -0800, David Miller wrote:
...
> Sorry, this structure is exported to userspace so we can't
> change it like that.
> 
> It is an attribute passed over netlink sockets.
> 

Thanks for finding this! I'll try to rethink this (especially why
my "tests" seemed to show something could be working there...).

Jarek P.
