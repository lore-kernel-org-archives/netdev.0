From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: avoid owner checks on IFF_ATTACH_QUEUE
Date: Thu, 10 Jan 2013 14:38:35 -0800 (PST)
Message-ID: <20130110.143835.2008690798301758570.davem@davemloft.net>
References: <20130110113108.GF13451@redhat.com>
	<20130110115503.GD30885@stefanha-thinkpad.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, jasowang@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: stefanha@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130110115503.GD30885@stefanha-thinkpad.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Hajnoczi <stefanha@redhat.com>
Date: Thu, 10 Jan 2013 12:55:03 +0100

> On Thu, Jan 10, 2013 at 01:31:08PM +0200, Michael S. Tsirkin wrote:
>> At the moment, we check owner when we enable queue in tun.
>> This seems redundant and will break some valid uses
>> where fd is passed around: I think TUNSETOWNER is there
>> to prevent others from attaching to a persistent device not
>> owned by them. Here the fd is already attached,
>> enabling/disabling queue is more like read/write.
>> 
>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>> 
>> ---
>> 
>> Note: this is unrelated to Stefan's bugfix.
> 
> This should go into 3.8-rc.
> 
> Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

Applied.
