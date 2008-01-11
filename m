From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 2/5] iwlwifi: iwl3945 synchronize
	interruptand tasklet for down iwlwifi
Date: Fri, 11 Jan 2008 10:24:54 +0900
Message-ID: <b25c3fa70801101724he91d934y9db6636c68a32486@mail.gmail.com>
References: <11998765481610-git-send-email-joonwpark81@gmail.com>
	<D936D925018D154694D8A362EEB08920035CCD70@orsmsx416.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Zhu, Yi" <yi.zhu@intel.com>,
	linux-wireless@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
	ipw3945-devel@lists.sourceforge.net
To: "Chatre, Reinette" <reinette.chatre@intel.com>
Return-path: <ipw3945-devel-bounces@lists.sourceforge.net>
In-Reply-To: <D936D925018D154694D8A362EEB08920035CCD70@orsmsx416.amr.corp.intel.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ipw3945-devel>
List-Post: <mailto:ipw3945-devel@lists.sourceforge.net>
List-Help: <mailto:ipw3945-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ipw3945-devel-bounces@lists.sourceforge.net
Errors-To: ipw3945-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hello Reinette,

2008/1/11, Chatre, Reinette <reinette.chatre@intel.com>:
>
> Could synchronize_irq() be moved into iwl_disable_interrupts() ? I am

At this time, iwl_disable_interrupts() can be called with irq
disabled, so for do that I think additional modification would be
needed.

> also wondering if we cannot call tasklet_kill() before
> iwl_disable_interrupts() ... thus preventing it from being scheduled
> when we are going down.

Thanks for your catch, it seems tasklet can re-enable interrupts.
I'll handle and make an another patch for them at this weekend :)

Thanks,
Joonwoo

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
