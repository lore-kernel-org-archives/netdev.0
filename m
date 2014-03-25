From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Revert "xen-netback: Aggregate TX unmap
 operations"
Date: Tue, 25 Mar 2014 18:58:24 -0400 (EDT)
Message-ID: <20140325.185824.890778229733178891.davem@davemloft.net>
References: <1395422584-16213-1-git-send-email-zoltan.kiss@citrix.com>
	<1395653207.19365.1.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zoltan.kiss@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org, paul.durrant@citrix.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jonathan.davies@citrix.com
To: Ian.Campbell@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395653207.19365.1.camel@kazak.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Mon, 24 Mar 2014 09:26:47 +0000

> On Fri, 2014-03-21 at 17:23 +0000, Zoltan Kiss wrote:
>> This reverts commit e9275f5e2df1b2098a8cc405d87b88b9affd73e6. This commit is the
>> last in the netback grant mapping series, and it tries to do more aggressive
>> aggreagtion of unmap operations. However practical use showed almost no
>> positive effect, whilst with certain frontends it causes significant performance
>> regression.
> 
> That's a shame -- do you have any insight into why?
> 
>> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> 
> Acked-by: Ian Campbell <ian.campbell@citrix.com>

Applied, thanks.
