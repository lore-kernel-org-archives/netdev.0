From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next v2 2/3] bonding: support QinQ for bond arp interval
Date: Wed, 19 Mar 2014 19:16:51 +0800
Message-ID: <53297CA3.9030005@huawei.com>
References: <1395139433-19576-1-git-send-email-dingtianhong@huawei.com> <1395139433-19576-3-git-send-email-dingtianhong@huawei.com> <20140318120558.GA6430@redhat.com> <7072.1395165598@death.nxdomain> <20140318192742.GB6430@redhat.com> <5328F2F5.6010304@huawei.com> <20140319053958.GA1242@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, <andy@greyhouse.net>,
	<kaber@trash.net>, <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:10458 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758087AbaCSLRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 07:17:22 -0400
In-Reply-To: <20140319053958.GA1242@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/3/19 13:39, Veaceslav Falico wrote:
> On Wed, Mar 19, 2014 at 09:29:25AM +0800, Ding Tianhong wrote:
> ...snip...
>> The QinQ didn't mean that the first(outer) tag must be 802.1ad, and the second(inner) tag must be 802.1q,
> 
> Do you have a quote for that from the standard? What I know and read
> everywhere is that the standard specifies the outer s-tag to always be
> 0x88A8.
> 
> The other thing is that we don't live in an ideal world and there are a
> lot of non-standard implementations out there, which might use 0x8100,
> 0x9100, 0x9200, 0x9300... for the outer s-tag, that's why using the
> user-provided proto is better.
> 
> 

Sorry for feedback so late, I'm too busy these days.

Agree, as far as I know, The original "QinQ" means "802.1Q in 802.1Q", but in practical applications,
the network operators could set the out tag to 0x9100, 0x8100 ... as they wished in the switch, this is no
limit, but in linux kernel the vlan only support 802.1ad and 801.1q, so we can only make choices in these values, 
so here I think let the user to decide the real proto is more reasonbale.

Regards
Ding
