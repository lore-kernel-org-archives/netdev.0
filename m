From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2] bridge: Fix garbled json output seen if a vlan
 filter is specified
Date: Sun, 9 Oct 2016 18:58:44 -0700
Message-ID: <20161009185844.39337a56@xeon-e3>
References: <1475858418-1618-1-git-send-email-anuradhak@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:32808 "EHLO
        mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751640AbcJJB63 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 21:58:29 -0400
Received: by mail-pa0-f41.google.com with SMTP id vu5so7982522pab.0
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2016 18:58:29 -0700 (PDT)
In-Reply-To: <1475858418-1618-1-git-send-email-anuradhak@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  7 Oct 2016 09:40:18 -0700
Anuradha Karuppiah <anuradhak@cumulusnetworks.com> wrote:

> From: anuradhak <anuradhak@cumulusnetworks.com>
> 
> json objects were started but not completed if the fdb vlan did not
> match the specified filter vlan.
> 
> Sample output:
> $ bridge -j fdb show vlan 111
> [{
>         "mac": "44:38:39:00:69:88",
>         "dev": "br0",
>         "vlan": 111,
>         "master": "br0",
>         "state": "permanent"
>     }
> ]
> $ bridge -j fdb show vlan 100
> []
> $
> 
> Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

Applied for 4.8 version
