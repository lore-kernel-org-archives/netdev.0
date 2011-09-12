From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2 6/9] per-cgroup tcp buffers control
Date: Mon, 12 Sep 2011 19:31:17 +0900
Message-ID: <20110912193117.d8f360f9.kamezawa.hiroyu@jp.fujitsu.com>
References: <1315369399-3073-1-git-send-email-glommer@parallels.com>
	<1315369399-3073-7-git-send-email-glommer@parallels.com>
	<20110909121206.e1d628d1.kamezawa.hiroyu@jp.fujitsu.com>
	<4E6A001C.2040600@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
 <containers@lists.osdl.org>, <netdev@vger.kernel.org>,
 <xemul@parallels.com>, "David S. Miller" <davem@davemloft.net>,
 "Eric W. Biederman" <ebiederm@xmission.com>
To: Glauber Costa <glommer@parallels.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <4E6A001C.2040600@parallels.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri, 9 Sep 2011 09:01:32 -0300
Glauber Costa <glommer@parallels.com> wrote:

> On 09/09/2011 12:12 AM, KAMEZAWA Hiroyuki wrote:
> > On Wed,  7 Sep 2011 01:23:16 -0300
> > Glauber Costa<glommer@parallels.com>  wrote:
> >
> >> With all the infrastructure in place, this patch implements
> >> per-cgroup control for tcp memory pressure handling.
> >>
> >> Signed-off-by: Glauber Costa<glommer@parallels.com>
> >> CC: David S. Miller<davem@davemloft.net>
> >> CC: Hiroyouki Kamezawa<kamezawa.hiroyu@jp.fujitsu.com>
> >> CC: Eric W. Biederman<ebiederm@xmission.com>
> >
> > Hmm, then, kmem_cgroup.c is just a caller of plugins implemented
> > by other components ?
> 
> Kame,
> 
> Refer to my discussion with Greg. How would you feel about it being 
> accounted to a single "kernel memory" limit in memcg?
> 

Hmm, it's argued that 'cgroup is hard to use, it's difficult!!!'.

Then, if implementation is clean, I think it may be good to add
kmem limit to memcg.

Your and Greg's idea is to have

	memory.kmem_limit_in_bytes 
?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
