From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCH v4 4/8] per-cgroup tcp buffers control
Date: Tue, 4 Oct 2011 09:43:32 +0400
Message-ID: <4E8A9D04.7060002@parallels.com>
References: <1317637123-18306-1-git-send-email-glommer@parallels.com> <1317637123-18306-5-git-send-email-glommer@parallels.com> <20111004101633.6b44201d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <paul@paulmenage.org>,
	<lizf@cn.fujitsu.com>, <ebiederm@xmission.com>, <davem@davemloft.net>,
	<gthelen@google.com>, <netdev@vger.kernel.org>, <linux-mm@kvack.org>,
	<kirill@shutemov.name>, <avagin@parallels.com>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20111004101633.6b44201d.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 10/04/2011 05:16 AM, KAMEZAWA Hiroyuki wrote:
> It seems memcg->tcp.tcp_memory_pressure has no locks and not atomic.
>
> no problematic race ?
>
> Thanks,
> -Kame
Well,

prior to this patch, it was a global variable. And nobody complained so 
far...

My impression is that the only thing that really needs to be atomic is
the memory accounting, which is already. If we miss a memory pressure 
condition entry, we'll get to it next time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
