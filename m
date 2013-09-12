From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2] tuntap: correctly handle error in tun_set_iff()
Date: Thu, 12 Sep 2013 17:22:41 -0400 (EDT)
Message-ID: <20130912.172241.886631046673790242.davem@davemloft.net>
References: <1378894188-8015-1-git-send-email-jasowang@redhat.com>
	<20130911104350.GA25316@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, wannes.rombouts@epitech.eu
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130911104350.GA25316@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Wed, 11 Sep 2013 13:43:50 +0300

> On Wed, Sep 11, 2013 at 06:09:48PM +0800, Jason Wang wrote:
>> Commit c8d68e6be1c3b242f1c598595830890b65cea64a
>> (tuntap: multiqueue support) only call free_netdev() on error in
>> tun_set_iff(). This causes several issues:
>> 
>> - memory of tun security were leaked
>> - use after free since the flow gc timer was not deleted and the tfile
>>   were not detached
>> 
>> This patch solves the above issues.
>> 
>> Reported-by: Wannes Rombouts <wannes.rombouts@epitech.eu>
>> Cc: Michael S. Tsirkin <mst@redhat.com>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>

Applied and queued up for -stable, thanks.
