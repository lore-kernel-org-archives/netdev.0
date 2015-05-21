From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v4 for-next 05/12] IB/cm: Share listening CM IDs
Date: Thu, 21 May 2015 10:07:45 +0300
Message-ID: <555D8441.8060609@mellanox.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
 <1431841868-28063-6-git-send-email-haggaie@mellanox.com>
 <20150519183545.GH18675@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150519183545.GH18675-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 19/05/2015 21:35, Jason Gunthorpe wrote:
...

> The share count should be 'listen_sharecount' because it *only* works
> for listen.
> 
> The above test in cm_destroy_id should only be in the listen branch of
> the if.

Okay.

> 
>> + * Create a new listening ib_cm_id and listen on the given service ID.
>> + *
>> + * If there's an existing ID listening on that same device and service ID,
>> + * return it.
>> + *
> 
> .. Callers should call cm_destroy_id when done with the listen ..

I'll add that (with ib_destroy_cm_id of course).

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
