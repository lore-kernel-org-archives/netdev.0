From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: neighbour: Remove CONFIG_ARPD
Date: Tue, 03 Sep 2013 21:42:02 -0400 (EDT)
Message-ID: <20130903.214202.2007386986702943063.davem@davemloft.net>
References: <8761upbd6h.fsf@xmission.com>
	<1377779927-28500-1-git-send-email-tim.gardner@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, ebiederm@xmission.com, gaofeng@cn.fujitsu.com,
	joe@perches.com, vfalico@redhat.com
To: tim.gardner@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377779927-28500-1-git-send-email-tim.gardner@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tim Gardner <tim.gardner@canonical.com>
Date: Thu, 29 Aug 2013 06:38:47 -0600

> This config option is superfluous in that it only guards a call
> to neigh_app_ns(). Enabling CONFIG_ARPD by default has no
> change in behavior. There will now be call to __neigh_notify()
> for each ARP resolution, which has no impact unless there is a
> user space daemon waiting to receive the notification, i.e.,
> the case for which CONFIG_ARPD was designed anyways.
> 
> Suggested-by: Eric W. Biederman <ebiederm@xmission.com>
 ...
> Signed-off-by: Tim Gardner <tim.gardner@canonical.com>

Applied, thanks.
