From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: Netlink messages without NLM_F_REQUEST flag
Date: Wed, 7 Jun 2017 18:26:01 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373AB141162@ORSMSX109.amr.corp.intel.com>
References: <20170607161901.GD1127@mtr-leonro.local>
 <20170607163758.GA25313@obsidianresearch.com>
 <CALq1K=Jj_jJ5_OAiiws-es37tFEsLeLJeSvnU+bfwd0KLkGM3Q@mail.gmail.com>
 <20170607164750.GA7507@obsidianresearch.com>
 <20170607170037.GG1127@mtr-leonro.local>
 <20170607170702.GB7507@obsidianresearch.com>
 <20170607181810.GI1127@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Wan, Kaike" <kaike.wan-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Fleck, John" <john.fleck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "Weiny, Ira" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        RDMA mailing list <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170607181810.GI1127-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> It is acking that message from user was received by kernel and now
> processing. The message from kernel to user are anyway unreliable [1],
> so I don't understand on which handshake you are talking.
> 
> [1] "reliable transmissions from kernel to user are impossible in any
> case"
> https://linux.die.net/man/7/netlink

The SA messages are kernel initiated messages that target a user space daemon (e.g. ibacm) for cached PR data.  If that fails because the daemon isn't running or the message is lost, the normal retry mechanism in the kernel should kick in and try sending the SA message to the remote (i.e. real) SA.

- Sean
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
