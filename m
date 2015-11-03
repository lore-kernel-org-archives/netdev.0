From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/core: fix for_each_netdev_feature
Date: Tue, 03 Nov 2015 11:34:56 -0500 (EST)
Message-ID: <20151103.113456.1360164920793289224.davem@davemloft.net>
References: <1446519359-21400-1-git-send-email-jarod@redhat.com>
	<1446563759-17713-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, edumazet@google.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	jiri@resnulli.us, razor@blackwall.org, mkubecek@suse.cz,
	alexander.duyck@gmail.com, geert@linux-m68k.org,
	netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446563759-17713-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarod Wilson <jarod@redhat.com>
Date: Tue,  3 Nov 2015 10:15:59 -0500

> As pointed out by Nikolay and further explained by Geert, the initial
> for_each_netdev_feature macro was broken, as feature would get set outside
> of the block of code it was intended to run in, thus only ever working for
> the first feature bit in the mask. While less pretty this way, this is
> tested and confirmed functional with multiple feature bits set in
> NETIF_F_UPPER_DISABLES.
 ...
> Fixes: fd867d51f ("net/core: generic support for disabling netdev features down stack")
 ...
> Signed-off-by: Jarod Wilson <jarod@redhat.com>

Applied.
