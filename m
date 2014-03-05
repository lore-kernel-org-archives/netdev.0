From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v6 1/10] xen-netback: Use skb->cb for pending_idx
Date: Wed, 5 Mar 2014 19:13:54 +0000
Message-ID: <53177772.60304@citrix.com>
References: <1393972341-21135-1-git-send-email-zoltan.kiss@citrix.com> <1393972341-21135-2-git-send-email-zoltan.kiss@citrix.com> <20140305121637.GF19620@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140305121637.GF19620@zion.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/03/14 12:16, Wei Liu wrote:
> On Tue, Mar 04, 2014 at 10:32:12PM +0000, Zoltan Kiss wrote:
>> Storing the pending_idx at the first byte of the linear buffer never looked
>> good, skb->cb is a more proper place for this. It also prevents the header to
>> be directly grant copied there, and we don't have the pending_idx after we
>> copied the header here, so it's time to change it.
>>
>
> I think this is a valid change. But I would like you to define a
> skb_cb_overlay just like the receive path does.
>
> You can rename skb_cb_overlay in current code to skb_cb_overlay_rx and
> add your skb_cb_overlay_tx.

Ok
