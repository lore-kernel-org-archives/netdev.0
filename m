From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: [PATCH v2 0/5] tipc: add TIPC over Infiniband support
Date: Wed, 17 Apr 2013 18:18:24 +0200
Message-ID: <1366215509-18500-1-git-send-email-kaber@trash.net>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, allan.stephens-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jon.maloy-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The following patchset adds support for running TIPC over InfiniBand.
The patchset consists of three parts (+ a minor fix for the ethernet media
type):

- Preparation: removal of an the unused str2addr callback and move of the
  bcast_addr from struct tipc_media to struct tipc_bearer. This is necessary
  because InfiniBand doesn't have a fixed broadcast address like ethernet,
  so it needs to be initialized with the device's broadcast address when
  the bearer is enabled

- Introduction of a TIPC InfiniBand media type. A new media type is needed
  to deal with the different address sizes

- Support for ETH_P_TIPC in IPoIB

Since the last posting I've addressed all feedback I received and rebased
to the current net-next tree.

I consider these patches ready for merging. Since they mainly affect TIPC
code, I'd propose to have them either go through the TIPC tree or through
Dave directly (not sure how TIPC patches are managed).

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
