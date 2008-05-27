From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 3/3] bnx2i: Add bnx2i iSCSI driver.
Date: Tue, 27 May 2008 11:21:32 -0700
Message-ID: <adaabibvc9f.fsf@cisco.com>
References: <1211418386-18203-1-git-send-email-mchan@broadcom.com>
	<1211418386-18203-4-git-send-email-mchan@broadcom.com>
	<ada8wy07osq.fsf@cisco.com>
	<1211578969.26900.5.camel@dhcp-10-13-110-217.broadcom.com>
	<adave0z24o4.fsf@cisco.com> <1211915874.18326.101.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Anil Veerabhadrappa" <anilgv@broadcom.com>,
	"David Miller" <davem@davemloft.net>, michaelc@cs.wisc.edu,
	netdev <netdev@vger.kernel.org>, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1211915874.18326.101.camel@dell> (Michael Chan's message of
	"Tue, 27 May 2008 12:17:54 -0700")
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > We're doing it in userspace, so I don't if that makes it any better or
 > any worse.

How do you do it in userspace?  With a bind()?  That is a little
wasteful in that you are reserving a local addr/port when all you really
need to reserve is the actual local/remote 4-tuple that you are going to
use for the connection, but that's not horrible.

 > Roland, what do you suggest?  We can do it like cma_alloc_any_port() in
 > cma.c.

Actually cma.c still has the problem of host/offload port space collisions.

The whole port sharing thing is a mess -- I was hoping you had come up
with a good solution that cma.c could steal to be honest, so I don't
have any better ideas at the moment.

 - R.
