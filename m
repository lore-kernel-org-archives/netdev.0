From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ibmvnic: Improve output for unsupported stats
Date: Mon, 02 Oct 2017 16:03:47 -0700 (PDT)
Message-ID: <20171002.160347.373058501691864578.davem@davemloft.net>
References: <6ce14d1a-11cc-37be-e6ca-b9ec4afb01a8@linux.vnet.ibm.com>
        <20171002215723.GN17713@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jallen@linux.vnet.ibm.com, netdev@vger.kernel.org,
        tlfalcon@linux.vnet.ibm.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52730 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751075AbdJBXDu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 19:03:50 -0400
In-Reply-To: <20171002215723.GN17713@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Mon, 2 Oct 2017 23:57:23 +0200

> On Mon, Oct 02, 2017 at 03:31:39PM -0500, John Allen wrote:
>> The vnic server can report -1 in the event that a given statistic is not
>> supported. Currently, the -1 value is implicitly cast to an unsigned
>> integer and appears through the ethtool -S output as a very large number.
>> This patch improves this behavior by reporting 0 in the event that a
>> given statistic is not supported.
> 
> Hi John
> 
> If it does not exist, why not skip it altogether?
> ibmvnic_get_sset_count() could walk the list and count the valid ones.
> ibmvnic_get_strings() could only return the name of the valid onces.

Agreed, skipping would be preferable to printing zero values.
