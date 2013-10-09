From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: don't look at current when non-blocking
Date: Wed, 09 Oct 2013 13:14:10 -0400 (EDT)
Message-ID: <20131009.131410.227391605999363505.davem@davemloft.net>
References: <20131008.154614.1435858706789904414.davem@davemloft.net>
	<5254F6CF.8080606@redhat.com>
	<20131009081354.GA30882@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, edumazet@google.com,
	xemul@parallels.com
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131009081354.GA30882@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Wed, 9 Oct 2013 11:13:54 +0300

> On Wed, Oct 09, 2013 at 02:25:19PM +0800, Jason Wang wrote:
>> On 10/09/2013 03:46 AM, David Miller wrote:
>> > From: "Michael S. Tsirkin" <mst@redhat.com>
>> > Date: Sun, 6 Oct 2013 21:25:12 +0300
>> >
>> >> We play with a wait queue even if socket is
>> >> non blocking. This is an obvious waste.
>> >> Besides, it will prevent calling the non blocking
>> >> variant when current is not valid.
>> >>
>> >> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>> > Applied and queued up for -stable, thanks.
>> > --
>> 
>> Michael, I believe this is just an optimization or a required patch of
>> your following patches. So no need go for stable?
> 
> I don't think it's required for stable.

Ok, removed from the -stable queue.  Thanks.
