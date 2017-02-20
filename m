From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [net-next][PATCH] RDS: keep data type consistent in the user
 visible header
Date: Mon, 20 Feb 2017 10:37:22 -0500
Message-ID: <20170220153722.GB16561@oracle.com>
References: <1487387747-5324-1-git-send-email-santosh.shilimkar@oracle.com>
 <20170220.101951.663166903772216217.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: santosh.shilimkar@oracle.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:48811 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752520AbdBTPhb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 10:37:31 -0500
Content-Disposition: inline
In-Reply-To: <20170220.101951.663166903772216217.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (02/20/17 10:19), David Miller wrote:
> 
> The correct fix it to use "__u8", "__u64", etc.

So the rest of rds.h uses uint8_t, uint32_t etc 
Perhaps (I'm not sure of the origins) this was because
of the shared OpenIB.org BSD license etc using __u8 in
one place and uint8_t in another would seem inconsistent,
at the very least.

--Sowmini
