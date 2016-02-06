From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 0/4] net: add and use rx_nohandler stat counter
Date: Sat, 06 Feb 2016 03:00:43 -0500 (EST)
Message-ID: <20160206.030043.153713563005660397.davem@davemloft.net>
References: <1453996188-29965-1-git-send-email-jarod@redhat.com>
	<1454370667-2328-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, edumazet@google.com,
	jiri@mellanox.com, daniel@iogearbox.net, tom@herbertland.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454370667-2328-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarod Wilson <jarod@redhat.com>
Date: Mon,  1 Feb 2016 18:51:03 -0500

 ...
> It seems additional counters never came to fruition, so this is a first
> attempt at creating one of them, so that we stop calling these drops,
> which for users monitoring rx_dropped, causes great alarm, and renders the
> counter much less useful for them.
> 
> This adds a sysfs statistics node and makes the counter available via
> netlink.
> 
> Additionally, I'm not certain if this set qualifies for net, or if it
> should be put aside and resubmitted for net-next after 4.5 is put to
> bed, but I do have users who consider this an important bugfix.
> 
> This has been tested quite a bit on x86_64, and now lightly on i686 as
> well, to verify functionality of updates to netdev_stats_to_stats64()
> on 32-bit arches.

Series applied, thanks Jarod.
