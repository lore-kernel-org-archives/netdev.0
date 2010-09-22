From: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Subject: software iwarp stack update
Date: Wed, 22 Sep 2010 10:19:56 +0200
Message-ID: <OF64770AFC.B48EBEF2-ONC12577A6.002CC793-C12577A6.002DC569@ch.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Earlier this year, we announced the availability of an open source,
full software implementation of the iWARP RDMA protocol stack - see
my email "software iwarp stack" from March 14th at the linux-rdma list
(http://www.mail-archive.com/linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg02940.html)
While since then working on performance and stability, we provided
some source code updates. Current user and kernel code is available at
gitorious.org/softiwarp. Please see the CHANGES file in the
kernel/ directory for a summary of the most recent changes.

For more convenient testing, the latest update now allows for a
stand-alone build of the kernel module without full kernel source
code access. We tested the code with kernel version 2.6.34. If
you are interested in a full software RDMA stack on Ethernet,
please try it out.

In the hope of providing useful information, I put
netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org on copy. Subscribers of this list,
please put me on private cc in case you reply or comment, since
I am not subscribed to the list.
We would be more than happy if you netdev folks would consider
a hardware independent RDMA kernel service as something useful and
potentially to be integrated into the mainline network stack.

Why might it be useful?
A software RDMA stack makes the semantic advantages of
asynchronous and one-sided communication available while obsoleting
the need to deploy dedicated RDMA hardware or any protocol offloading
(while not matching the lowest delay numbers of real RDMA hardware).
Implementing the IETF's iWARP protocol stack on top of TCP kernel
sockets, softiwarp integrates with the open fabrics environment
and thus exports the RDMA kernel and user verbs interface.

The efficiency of the Linux TCP/IP network stack together with intrinsic
advantages of the RDMA communication model (async. posting of work
and reaping of work completions, transfer of send buffer ownership
to the kernel which enables zero copy transmit, peer data placement
without application scheduling, one-sided remote read operations etc.)
can result in improved application-to-application performance and
less CPU load, while using the unchanged kernel TCP stack.

A software RDMA stack might promote wider RDMA deployment,
since when using the host TCP stack, it enables RDMA semantic
independent of dedicated hardware. softiwarp peers with real
RNICs (tested with Chelsio's T3 adapter).

softiwarp is still work in progress and we are very thankful for any
suggestions/comments/bug reports. Please advise how we should proceed
to bring the stack further to your attention. Would it be useful to
provide patches against the current stable kernel version or the next
release candidate?

Many thanks,
Bernard.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
