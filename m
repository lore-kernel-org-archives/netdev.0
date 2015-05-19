From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Tue, 19 May 2015 12:38:43 -0600
Message-ID: <20150519183843.GI18675@obsidianresearch.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
 <1432045826.5304.6.camel@opteya.com>
 <555B4EBE.7010900@mellanox.com>
 <CAGgvQNRjSVcOfQB3bhXTdPoa04Hs7jc1+hXvL99EqDjbaaOw=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yann Droneaud <ydroneaud-RlY5vtjFyJ3QT0dZR+AlfA@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Parav Pandit <parav.pandit-1wcpHE2jlwO1Z/+hSey0Gg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAGgvQNRjSVcOfQB3bhXTdPoa04Hs7jc1+hXvL99EqDjbaaOw=A@mail.gmail.com>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 19, 2015 at 10:09:14PM +0530, Parav Pandit wrote:

> A callback function registered to IP stack for IP address
> assignment/removal. (it could be done possibly done for GID entry
> update, instead of IP)
> For each such namespace, for device supporting RoCEv2, one UDP socket
> with RoCEv2 UDP port would be created and destroyed.

You need to consult netdev for whatever scheme you come up with.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
