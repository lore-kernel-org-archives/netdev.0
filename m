From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH v2 net-next RFC] Generic XDP
Date: Mon, 10 Apr 2017 17:33:25 -0400
Message-ID: <20170410213325.GD4730@C02RW35GFVH8.dhcp.broadcom.net>
References: <20170409.133528.660876505013192371.davem@davemloft.net>
 <20170410183935.GB4730@C02RW35GFVH8.dhcp.broadcom.net>
 <20170410.153456.2120460675454633725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:34186 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752877AbdDJVdc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 17:33:32 -0400
Received: by mail-qt0-f179.google.com with SMTP id c45so75149426qtb.1
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 14:33:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170410.153456.2120460675454633725.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 10, 2017 at 03:34:56PM -0400, David Miller wrote:
> From: Andy Gospodarek <andy@greyhouse.net>
> Date: Mon, 10 Apr 2017 14:39:35 -0400
> 
> > I also noted that...
> > 
> > xdp1 not parsing the protocol correctly.   All traffic was showing up as
> > protocol '0' instead of '17' in the output.  
> > 
> > xdp2 was not actually sending the frames back out when using this patch.
> > 
> > I'll take a look in a bit and see if I can track these two issues down.
> 
> Read Alexei's earlier posting, he spotted the bugs you are seeing
> here.
> 
> Basically, the MAC header is pulled already so we have to push it back
> before we run XDP over it.  We also have to be similarly careful with
> the MAC header for XDP_TX cases.

Yep, I saw those emails.  I just didn't want to be accused of not running all
the tests.  :-D 
