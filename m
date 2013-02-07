From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH 06/10] netfilter: ipt_ulog: add net namespace support
 for ipt_ulog
Date: Thu, 07 Feb 2013 15:57:50 +0800
Message-ID: <51135E7E.9020301@cn.fujitsu.com>
References: <1360223390-15589-1-git-send-email-gaofeng@cn.fujitsu.com> <1360223390-15589-6-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Gao feng <gaofeng@cn.fujitsu.com>, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org, ebiederm@xmission.com,
	netdev@vger.kernel.org, lve@guap.ru
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1360223390-15589-6-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pablo,

On 2013/02/07 15:49, Gao feng wrote:
> Add pernet_operations for ipt_ulog, in pernet_ops,
> we call nf_log_set/unset to set/unset nf_loggers
> of per net.
> 
> This patch also make ulog_buffers and netlink socket
> nflognl per netns.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>

Please take care this patch,it's base on the prev two patches
"ulog: add protection when remove ipt_ULOG" and
"netfilter: ipt_ULOG: make spinlock per nlgroup" which I send on
2013/02/05.

If you think this patchset is ok and intend to apply it,you should
apply the prev two patches before apply this patchset.

BTW,I will out of office until 2/18,I will response your comments
as soon as I come back.

Thanks!
