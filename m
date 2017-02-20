From: David Miller <davem@davemloft.net>
Subject: Re: [net-next][PATCH] RDS: keep data type consistent in the user
 visible header
Date: Mon, 20 Feb 2017 10:39:12 -0500 (EST)
Message-ID: <20170220.103912.194197218422769191.davem@davemloft.net>
References: <1487387747-5324-1-git-send-email-santosh.shilimkar@oracle.com>
        <20170220.101951.663166903772216217.davem@davemloft.net>
        <20170220153722.GB16561@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santosh.shilimkar@oracle.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170220153722.GB16561@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Mon, 20 Feb 2017 10:37:22 -0500

> On (02/20/17 10:19), David Miller wrote:
>> 
>> The correct fix it to use "__u8", "__u64", etc.
> 
> So the rest of rds.h uses uint8_t, uint32_t etc 
> Perhaps (I'm not sure of the origins) this was because
> of the shared OpenIB.org BSD license etc using __u8 in
> one place and uint8_t in another would seem inconsistent,
> at the very least.

The entire file should use the proper "__uX" kernel types
rather than the uint* ones.
