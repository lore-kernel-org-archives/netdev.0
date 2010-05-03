From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: show stopped status in sysfs
Date: Mon, 03 May 2010 15:04:42 -0700 (PDT)
Message-ID: <20100503.150442.140757825.davem@davemloft.net>
References: <20100503212423.GA15998@redhat.com>
	<1272923093.27948.63.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, eric.dumazet@gmail.com, ebiederm@xmission.com,
	johannes@sipsolutions.net, therbert@google.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1272923093.27948.63.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 03 May 2010 22:44:53 +0100

> On Tue, 2010-05-04 at 00:24 +0300, Michael S. Tsirkin wrote:
>> When debugging faulty hardware (in case of virt, faulty
>> emulation) I found it helpful to be able to examine
>> stopped status of the interface. The following patch makes
>> this visible in sysfs.
> [...]
> 
> This is a per-queue attribute and should not be associated directly with
> the netdev.

Right.
