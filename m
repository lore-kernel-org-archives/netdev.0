From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCH v2 6/9] per-cgroup tcp buffers control
Date: Fri, 9 Sep 2011 09:01:32 -0300
Message-ID: <4E6A001C.2040600@parallels.com>
References: <1315369399-3073-1-git-send-email-glommer@parallels.com> <1315369399-3073-7-git-send-email-glommer@parallels.com> <20110909121206.e1d628d1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
	<containers@lists.osdl.org>, <netdev@vger.kernel.org>, <xemul@parallels.com>,
	"David S. Miller" <davem@davemloft.net>, "Eric W. Biederman"
	<ebiederm@xmission.com>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20110909121206.e1d628d1.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 09/09/2011 12:12 AM, KAMEZAWA Hiroyuki wrote:
> On Wed,  7 Sep 2011 01:23:16 -0300
> Glauber Costa<glommer@parallels.com>  wrote:
>
>> With all the infrastructure in place, this patch implements
>> per-cgroup control for tcp memory pressure handling.
>>
>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>> CC: David S. Miller<davem@davemloft.net>
>> CC: Hiroyouki Kamezawa<kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Eric W. Biederman<ebiederm@xmission.com>
>
> Hmm, then, kmem_cgroup.c is just a caller of plugins implemented
> by other components ?

Kame,

Refer to my discussion with Greg. How would you feel about it being 
accounted to a single "kernel memory" limit in memcg?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
