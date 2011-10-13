From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7 0/8] Request for inclusion: tcp memory buffers
Date: Thu, 13 Oct 2011 16:00:31 -0400 (EDT)
Message-ID: <20111013.160031.605700447623532119.davem@davemloft.net>
References: <1318511382-31051-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
        lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com,
        ebiederm@xmission.com, paul@paulmenage.org, gthelen@google.com,
        netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name,
        avagin@parallels.com, devel@openvz.org
To: glommer@parallels.com
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1318511382-31051-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Glauber Costa <glommer@parallels.com>
Date: Thu, 13 Oct 2011 17:09:34 +0400

> This series was extensively reviewed over the past month, and after
> all major comments were merged, I feel it is ready for inclusion when
> the next merge window opens. Minor fixes will be provided if they
> prove to be necessary.

I'm not applying this.

You're turning inline increments and decrements of the existing memory
limits into indirect function calls.

That imposes a new non-trivial cost, in fast paths, even when people
do not use your feature.

Make this evaluate into exactly the same exact code stream we have
now when the memory cgroup feature is not in use, which will be the
majority of users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
