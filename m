From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v6 6/8] tcp buffer limitation: per-cgroup limit
Date: Thu, 13 Oct 2011 14:58:51 +0900
Message-ID: <20111013145851.4a3739ee.kamezawa.hiroyu@jp.fujitsu.com>
References: <1318242268-2234-1-git-send-email-glommer@parallels.com>
	<1318242268-2234-7-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com,
 ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com,
 netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name,
 avagin@parallels.com, devel@openvz.org
To: Glauber Costa <glommer@parallels.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1318242268-2234-7-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 10 Oct 2011 14:24:26 +0400
Glauber Costa <glommer@parallels.com> wrote:

> This patch uses the "tcp_max_mem" field of the kmem_cgroup to
> effectively control the amount of kernel memory pinned by a cgroup.
> 
> We have to make sure that none of the memory pressure thresholds
> specified in the namespace are bigger than the current cgroup.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Eric W. Biederman <ebiederm@xmission.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
