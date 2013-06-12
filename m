From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] tuntap: set SOCK_ZEROCOPY flag during open
Date: Wed, 12 Jun 2013 00:45:33 -0700 (PDT)
Message-ID: <20130612.004533.1565702065831087835.davem@davemloft.net>
References: <1370672261-30076-1-git-send-email-jasowang@redhat.com>
	<20130611131750.GD9279@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130611131750.GD9279@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 11 Jun 2013 16:17:50 +0300

> On Sat, Jun 08, 2013 at 02:17:41PM +0800, Jason Wang wrote:
>>Cc: smtp.corp.redhat.com@redhat.com, davem@davemloft.net,
>>	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
>>
>> Commit 54f968d6efdbf7dec36faa44fc11f01b0e4d1990
>> (tuntap: move socket to tun_file) forgets to set SOCK_ZEROCOPY flag, which will
>> prevent vhost_net from doing zercopy w/ tap. This patch fixes this by setting
>> it during file open.
>> 
>> Cc: Michael S. Tsirkin <mst@redhat.com>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> 
> One of the addresses in the Cc list (smtp.corp.redhat.com@redhat.com)
> is clearly a mistake, which probably explains why it didn't
> get into patchwork.
> 
> I have bounced it to correct addresses, hope this
> helps instead of making even more of a mess of it.
> 
> For 3.10 and -stable:
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>

Applied and queued up for -stable, thanks.
