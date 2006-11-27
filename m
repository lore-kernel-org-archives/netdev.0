From: Thomas Graf <tgraf@suug.ch>
Subject: Re: RFC: remove NET_CLS_POLICE?
Date: Mon, 27 Nov 2006 09:56:14 +0100
Message-ID: <20061127085614.GT8693@postel.suug.ch>
References: <20061126062939.GM15364@stusta.de> <456994ED.9040405@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@stusta.de>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:17879 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1757487AbWK0Izz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 03:55:55 -0500
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <456994ED.9040405@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Patrick McHardy <kaber@trash.net> 2006-11-26 14:21
> One more thing NET_CLS_POLICE affects is CBQ reshape/reclassify
> handling, reshape_fail seems to be completely unhandled without
> NET_CLS_POLICE and reclassification looks like it behaves
> differently with tc actions. I'm not really sure what the
> reshape_fail stuff is used for, but it looks like we would loose
> a feature. Jamal?

Yes, this is the reason why it wasn't removed yet. It always
occured to me as a mystery why NET_ACT_POLICE didn't depend
on the same logic inside the qdiscs. That needs to be resolved
first. Also the compat code for the action variant to handle
old policer configurations is horrible and should be done in
a clear way.

