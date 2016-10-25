From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: question about function igmp_stop_timer() in net/ipv4/igmp.c
Date: Tue, 25 Oct 2016 14:19:36 +0200
Message-ID: <20161025121936.GI22417@lunn.ch>
References: <580DF574.6070905@hisilicon.com>
 <20161024153200.GM1110@lunn.ch>
 <580EB1D2.3010309@hisilicon.com>
 <20161025073913.GA20223@lunn.ch>
 <580F471D.5050204@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Dongpo Li <lidongpo@hisilicon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53602 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752975AbcJYMTj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Oct 2016 08:19:39 -0400
Content-Disposition: inline
In-Reply-To: <580F471D.5050204@hisilicon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Otherwise the host can't send IGMP leave message when it leaves the
> group because the im->reporter is 0.

Leave is optional for IGMP v2, so net sending it is fine. And only a
querier is going to take any notice of it.

What happens when you have a querier in your network and you are using
IGMPv3. That is the use case which matters.

     Andrew
