From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Thu, 28 May 2015 16:22:36 +0300
Message-ID: <5567169C.60206@mellanox.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
	 <1432647280.28905.107.camel@redhat.com>
	 <20150526165928.GC11800@obsidianresearch.com>
 <1432662396.28905.157.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1432662396.28905.157.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 26/05/2015 20:46, Doug Ledford wrote:
>> Remember, this isn't RDMA namespaces, this is netdev namespace support
>> > for RDMA-CM -> very different things.
> That was the point of my email.  This is a very myopic view of the
> feature.  It *should* at least have an idea of these other things too.

We did give some thought to the question of whether an RDMA namespace is
needed, and concluded that it isn't. RDMA resources such as QP numbers,
memory keys, etc. are allocated by the devices. So different containers
wouldn't care if they share the "QP number namespace", etc. RDMA CM
ports are different because they are chosen by the applications, but
they map directly to the network namespace, so they don't require their
own namespace.

Regards,
Haggai

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
