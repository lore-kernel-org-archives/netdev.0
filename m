From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvtap: fix the uninitialized var using in
 macvtap_alloc_skb()
Date: Tue, 20 Sep 2011 14:48:12 -0400 (EDT)
Message-ID: <20110920.144812.2183953543808463400.davem@davemloft.net>
References: <20110919094830.6272.40503.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
	<20110919095415.GD4501@redhat.com>
	<1316516283.3891.27.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, jasowang@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dan.carpenter@oracle.com
To: Ian.Campbell@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1316516283.3891.27.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Tue, 20 Sep 2011 11:58:03 +0100

> On Mon, 2011-09-19 at 12:54 +0300, Michael S. Tsirkin wrote:
>> On Mon, Sep 19, 2011 at 05:48:31PM +0800, Jason Wang wrote:
>> > Commit d1b08284 use new frag API but would leave f to be used
>> > uninitialized, this patch fix it.
>> > 
>> > Signed-off-by: Jason Wang <jasowang@redhat.com>
>> 
>> Good catch. Makes absolute sense.
>> 
>> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> 
> Agreed. I like this one better than the one I just sent out so:
> 
> Acked-by: Ian Campbell <ian.campbell@citrix.com>

Applied.
