From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 1/7] Basic kernel memory functionality for the Memory
 Controller
Date: Wed, 28 Sep 2011 09:58:26 +0900
Message-ID: <20110928095826.eb8ebc8c.kamezawa.hiroyu@jp.fujitsu.com>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com>
	<1316393805-3005-2-git-send-email-glommer@parallels.com>
	<20110926193451.b419f630.kamezawa.hiroyu@jp.fujitsu.com>
	<4E81084F.9010208@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <paul@paulmenage.org>,
 <lizf@cn.fujitsu.com>, <ebiederm@xmission.com>, <davem@davemloft.net>,
 <gthelen@google.com>, <netdev@vger.kernel.org>, <linux-mm@kvack.org>,
 <kirill@shutemov.name>
To: Glauber Costa <glommer@parallels.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <4E81084F.9010208@parallels.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 26 Sep 2011 20:18:39 -0300
Glauber Costa <glommer@parallels.com> wrote:

> On 09/26/2011 07:34 AM, KAMEZAWA Hiroyuki wrote:
> > On Sun, 18 Sep 2011 21:56:39 -0300
> > Glauber Costa<glommer@parallels.com>  wrote:
"If parent sets use_hierarchy==1, children must have the same kmem_independent value
> > with parant's one."
> >
> > How do you think ? I think a hierarchy must have the same config.
> BTW, Kame:
> 
> Look again (I forgot myself when I first replied to you)
> Only in the root cgroup those files get registered.
> So shouldn't be a problem, because children won't even
> be able to see them.
> 
> Do you agree with this ?
> 

agreed.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
