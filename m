From: Bhaktipriya Shridhar <bhaktipriya96-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] libertas_tf: Remove create_workqueue
Date: Tue, 28 Jun 2016 22:20:11 +0530
Message-ID: <CAFNHFT8_4P3h1Ou0PZ6d4tPbJ1ysb5JjPc=NL2GiVO-tUZAp5g@mail.gmail.com>
References: <20160607200853.GA13742@Karyakshetra> <20160611224708.GC31708@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160611224708.GC31708-piEFEHQLUPpN0TnZuCh8vA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ping!
Thanks,
Bhaktipriya


On Sun, Jun 12, 2016 at 4:17 AM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> On Wed, Jun 08, 2016 at 01:38:53AM +0530, Bhaktipriya Shridhar wrote:
>> alloc_workqueue replaces deprecated create_workqueue().
>>
>> A dedicated workqueue has been used since the workitem (viz
>> &priv->cmd_work per priv, which maps to lbtf_cmd_work) is involved in
>> actual command processing and may be used on a memory reclaim path.
>> The workitems require forward progress under memory pressure and hence,
>> WQ_MEM_RECLAIM has been set. Since there are only a fixed number of work
>> items, explicit concurrency limit is unnecessary here.
>>
>> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>
> Acked-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>
> Thanks.
>
> --
> tejun
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
