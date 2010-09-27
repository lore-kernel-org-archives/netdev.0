From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/9p: Mount only matching virtio channels
Date: Mon, 27 Sep 2010 15:54:14 -0700 (PDT)
Message-ID: <20100927.155414.43043854.davem@davemloft.net>
References: <1285514893-11233-1-git-send-email-sven.eckelmann@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ericvh@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sven.eckelmann@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1285514893-11233-1-git-send-email-sven.eckelmann@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven.eckelmann@gmx.de>
Date: Sun, 26 Sep 2010 17:28:13 +0200

> p9_virtio_create will only compare the the channel's tag characters
> against the device name till the end of the channel's tag but not till
> the end of the device name. This means that if a user defines channels
> with the tags foo and foobar then he would mount foo when he requested
> foonot and may mount foo when he requested foobar.
> 
> Thus it is necessary to check both string lengths against each other in
> case of a successful partial string match.
> 
> Signed-off-by: Sven Eckelmann <sven.eckelmann@gmx.de>

I'll apply this, but this code would be so much simpler and this bug
would have never happened if these tags were NULL terminated when they
were pulled in from virtio.
