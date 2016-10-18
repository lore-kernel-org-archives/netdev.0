From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH] net: dsa: properly disconnect the slave PHYs
Date: Tue, 18 Oct 2016 15:27:41 +0200
Message-ID: <08bfeefe-14bd-409a-3d05-7fd9fd26b5f3@phrozen.org>
References: <1476792760-60356-1-git-send-email-john@phrozen.org>
 <20161018122909.GR26778@lunn.ch>
 <a310cfb9-8000-3906-242e-501900d5c8a0@phrozen.org>
 <20161018132413.GU26778@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:38776 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755336AbcJRN1q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Oct 2016 09:27:46 -0400
In-Reply-To: <20161018132413.GU26778@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 18/10/2016 15:24, Andrew Lunn wrote:
>> Hi Andrew
>>
>> i am testing on v4.4 which did not have a phy_disconnect() call. this
>> seems to have been fixed by cda5c15b so please ignore this patch
> 
> Hi John
> 
> All patches must be against net-next, or net if it is a fix. Anything
> else is wrong....
> 
>      Andrew
> 

Hi Andrew,

i know. i was testing on v4.4 and then rebased the patch against
net-next without noticing that a similar patch had already been merged.

regardless, using the latest net-next tree, the oops is gone without
adding any patches.

	John
