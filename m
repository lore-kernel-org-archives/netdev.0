From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next iproute2 1/3] netlink: import netlink message
 parsing from kernel
Date: Tue, 2 May 2017 11:03:14 -0700
Message-ID: <20170502110314.66d9ee89@xeon-e3>
References: <1493695105-9418-2-git-send-email-dsa@cumulusnetworks.com>
        <20170502082531.43b32e05@xeon-e3>
        <7fa44ec5-9a3a-55d1-b058-540d37ef01bd@cumulusnetworks.com>
        <20170502.130032.1854491688518080191.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org,
        jakub.kicinski@netronome.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35893 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750939AbdEBSDR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 14:03:17 -0400
Received: by mail-pf0-f171.google.com with SMTP id q66so756760pfi.3
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 11:03:17 -0700 (PDT)
In-Reply-To: <20170502.130032.1854491688518080191.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 02 May 2017 13:00:32 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Tue, 2 May 2017 10:51:23 -0600
> 
> > On 5/2/17 9:25 AM, Stephen Hemminger wrote:  
> >> Please either use existing netlink attribute code in libnetlink.h
> >> (rta_getattr_u32 etc) or use libmnl like devlink.  
> > 
> > All of the existing rta_ functions take a struct rta_attr; netlink
> > messages use struct nlattr. It's just wrong to use rta functions for
> > netlink messages.  
> 
> Agreed.
> 
> > There is no existing parse function for nlattr. There is no existing
> > validate function - for nlattr or rta_attr. So I do not see any overlap
> > with existing code.  
> 
> Also agreed.

Then use libmnl it is already used in several other places in iproute2.
Eventually, I would like to use it everywhere and get rid of old netlink parser.
