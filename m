From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] Drivers: net-next: hyperv: Fix a bug in
 netvsc_start_xmit()
Date: Sun, 28 Sep 2014 23:16:47 -0400 (EDT)
Message-ID: <20140928.231647.1355757349883305047.davem@davemloft.net>
References: <1411958991-28049-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
	jasowang@redhat.com, stable@vger.kernel.org
To: kys@microsoft.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1411958991-28049-1-git-send-email-kys@microsoft.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Sun, 28 Sep 2014 19:49:51 -0700

> After the packet is successfully sent, we should not touch the skb as it may
> have been freed. This patch is based on the work done by
> Long Li <longli@microsoft.com>. 
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> Tested-by: Long Li <longli@microsoft.com>
> Cc: <stable@vger.kernel.org>

You hyperv guys really have to get your act together.  This is not
properly submitted.

Most importantly, this is a serious reference to free memory bug.
Therefore it should be targetted at 'net' not 'net-next'.

Secondly, you do not CC: stable for networking changes, you instead
ask me to queue it up for my next batch of -stable networking changes.

Thirdly, your Subject line is malformed.  You should not use
"Drivers: " as a prefix.  Just the driver name is sufficient.
You should also not mentionen the target GIT tree outside of the
[PATCH ...] bracketed area.

Also, please be cognizant of how much of my time you unnecessarily
consume when you make a malformed submission like this.  That is
time I could spend reviewing other patches.

Thank you.
