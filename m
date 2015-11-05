From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net/core: ensure features get disabled on
 new lower devs
Date: Wed, 04 Nov 2015 21:56:32 -0500 (EST)
Message-ID: <20151104.215632.964832400121049446.davem@davemloft.net>
References: <1446583017-19021-1-git-send-email-jarod@redhat.com>
	<1446610172-21420-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, edumazet@google.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	jiri@resnulli.us, razor@blackwall.org, mkubecek@suse.cz,
	alexander.duyck@gmail.com, netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446610172-21420-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarod Wilson <jarod@redhat.com>
Date: Tue,  3 Nov 2015 23:09:32 -0500

> With moving netdev_sync_lower_features() after the .ndo_set_features
> calls, I neglected to verify that devices added *after* a flag had been
> disabled on an upper device were properly added with that flag disabled as
> well. This currently happens, because we exit __netdev_update_features()
> when we see dev->features == features for the upper dev. We can retain the
> optimization of leaving without calling .ndo_set_features with a bit of
> tweaking and a goto here.
> 
> Fixes: fd867d51f889 ("net/core: generic support for disabling netdev features down stack")
 ...
> Reported-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Signed-off-by: Jarod Wilson <jarod@redhat.com>
> ---
> v2: Based on suggestions from Alex, and with not changing err to ret, this
> patch actually becomes quite minimal and doesn't ugly up the code much.

Applied, thanks.
