From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [RFC: 2.6 patch] hostap_hw.c:hfa384x_set_rid(): fix error handling
Date: Sun, 12 Mar 2006 17:15:38 -0800
Message-ID: <20060313011538.GU9383@jm.kir.nu>
References: <20060309230646.GI21864@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hostap@shmoo.com, linux-kernel@vger.kernel.org,
	linville@tuxdriver.com
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20060309230646.GI21864@stusta.de>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://lists.shmoo.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Fri, Mar 10, 2006 at 12:06:46AM +0100, Adrian Bunk wrote:

> The Coverity checker noted that the call to prism2_hw_reset() was dead 
> code.
> 
> Does this patch change the code to what was intended?

Thanks! Based on my CVS history, it looks like this was broken in 2002
when the access command was moved from another function and verification
of -ETIMEDOUT value was not moved correctly. The original behavior would
be achieved by changing your patch to call printk first before the moved
prism2_hw_reset(dev) call. I added this (with the re-ordered printk) to
my queue for wireless-2.6.

-- 
Jouni Malinen                                            PGP id EFC895FA
