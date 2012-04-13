From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8139cp: set intr mask after its handler is registered
Date: Fri, 13 Apr 2012 13:42:43 -0400 (EDT)
Message-ID: <20120413.134243.2000744517368456334.davem@davemloft.net>
References: <20120412081053.25774.41676.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<20120412104529.27ece685@asterix.rh>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: fbl@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120412104529.27ece685@asterix.rh>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Flavio Leitner <fbl@redhat.com>
Date: Thu, 12 Apr 2012 10:45:29 -0300

> On Thu, 12 Apr 2012 16:10:54 +0800
> Jason Wang <jasowang@redhat.com> wrote:
> 
>> We set intr mask before its handler is registered, this does not work well when
>> 8139cp is sharing irq line with other devices. As the irq could be enabled by
>> the device before 8139cp's hander is registered which may lead unhandled
>> irq. Fix this by introducing an helper cp_irq_enable() and call it after
>> request_irq().
>> 
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> 
> Reviewed-by: Flavio Leitner <fbl@redhat.com>

Applied, and queued up for -stable, thanks.
