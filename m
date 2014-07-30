From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH v4] net: kernel-doc compliant documentation for net_device
Date: Wed, 30 Jul 2014 10:17:53 -0700
Message-ID: <53D928C1.9070107@infradead.org>
References: <1406728663-3848-1-git-send-email-karoly.kemeny@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Karoly Kemeny <karoly.kemeny@gmail.com>, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1406728663-3848-1-git-send-email-karoly.kemeny@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/30/14 06:57, Karoly Kemeny wrote:
> Net_device is a vast and important structure, but it has no kernel-doc
> compliant documentation. This patch extracts the comments from the structure
> to clean it up, and let the scripts extract documentation from it. I know that
> the patch is big, but it's just reordering of comments into the appropriate 
> form, and adding a few more, for the missing members.
> 
> v2: 
> Additional documentation added for some members (gflags,neigh_priv_len,
> queues_kset, uc_promisc, promiscuity, allmulti, _rx, _tx, watchdog_timer,
> rtnl_link_state, tstats, gso_max_size, gso_max_segs, num_tc, pm_qos_req).
> Cleaned up trailing whitespaces and blank lines.
> Fixed the beginning to indicate kernel-doc notation.
> 
> v3:
> Fixed typos.
> Added documentation for npinfo and stats
> 
> v4:
> Fixed further typos pointed out by Nikolay
> 
> Signed-off-by: Karoly Kemeny <karoly.kemeny@gmail.com>

Acked-by: Randy Dunlap <rdunlap@infradead.org>

Thank you.

> ---
>  include/linux/netdevice.h | 381 ++++++++++++++++++++++++++++++----------------
>  1 file changed, 250 insertions(+), 131 deletions(-)



-- 
~Randy
