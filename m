From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [v3 PATCH 0/2] rhashtable: rhashtable with duplicate objects
Date: Tue, 20 Sep 2016 04:44:19 -0400 (EDT)
Message-ID: <20160920.044419.79616518616678600.davem@davemloft.net>
References: <20160919105854.GA12892@gondor.apana.org.au>
        <1474283023.6544.0.camel@sipsolutions.net>
        <1474284732.6544.2.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org, tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org,
        greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1474284732.6544.2.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Mon, 19 Sep 2016 13:32:12 +0200

> On Mon, 2016-09-19 at 13:03 +0200, Johannes Berg wrote:
>> On Mon, 2016-09-19 at 18:58 +0800, Herbert Xu wrote:
>> > 
>> > v3 fixes a bug in the remove path that causes the element count
>> > to decrease when it shouldn't, leading to a gigantic hash table
>> > when it underflows.
>> > 
>> Ok, with the BUG_ON() thrown in, this works in the test that was
>> failing before. I'll run the entire suite again over lunch.
>> 
> 
> Ok, the entire test suite passed (with the BUG_ON, but hey).
> 
> Dave, let me know what you want to do (or have done, as it may be).

I'll apply this directly to net-next and push it out after some
build testing.

Thanks guys.
