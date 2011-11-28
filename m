From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v6 08/10] Display current tcp failcnt in kmem cgroup
Date: Mon, 28 Nov 2011 13:21:28 +0900
Message-ID: <20111128132128.e9a0774d.kamezawa.hiroyu@jp.fujitsu.com>
References: <1322242696-27682-1-git-send-email-glommer@parallels.com>
	<1322242696-27682-9-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, lizf@cn.fujitsu.com,
 ebiederm@xmission.com, davem@davemloft.net, paul@paulmenage.org,
 gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org,
 kirill@shutemov.name, avagin@parallels.com, devel@openvz.org,
 eric.dumazet@gmail.com, cgroups@vger.kernel.org
To: Glauber Costa <glommer@parallels.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1322242696-27682-9-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri, 25 Nov 2011 15:38:14 -0200
Glauber Costa <glommer@parallels.com> wrote:

> This patch introduces kmem.tcp.failcnt file, living in the
> kmem_cgroup filesystem. Following the pattern in the other
> memcg resources, this files keeps a counter of how many times
> allocation failed due to limits being hit in this cgroup.
> The root cgroup will always show a failcnt of 0.
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
