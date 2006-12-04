From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC][GENETLINK] move command capabilities  to flags
Date: Mon, 4 Dec 2006 10:20:41 +0100
Message-ID: <20061204092041.GN8693@postel.suug.ch>
References: <1165060612.3564.8.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:29326 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1759851AbWLDJUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 04:20:20 -0500
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1165060612.3564.8.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-12-02 06:56
> 
> Dave,
> If there is no objections on this approach, please apply this patch.
> Against net-2.6.20
> 
> cheers,
> jamal

> This patch moves command capabilities to command flags. Other than
> being cleaner, saves several bytes.

Is it worth to save these 12 bytes by breaking compatibility? If you
really want to do it, remove the obsoleted attribute types, I don't
like dead bodies laying around :-)
