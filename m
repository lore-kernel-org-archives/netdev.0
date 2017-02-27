From: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Subject: ANNOUNCE: Netdev 2.1 update Feb 27
Date: Mon, 27 Feb 2017 08:43:14 -0500
Message-ID: <f43e06f4-cd52-6d98-c585-8243f1a002be@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        info-Aq7fehzYRUagpaxmtUs7hg@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        tech-committee-Aq7fehzYRUagpaxmtUs7hg@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Stephen Jaworski <jaws-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, lwn-T1hC0tSOHrs@public.gmane.org,
        people-Aq7fehzYRUagpaxmtUs7hg@public.gmane.org, Brenda Butler <bjb-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
To: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

A few announcements:

1) The CFP is now officially closed. Thanks to everyone who submitted.

2) We are extending the early registration to March 5.

Register early so we can plan better (and so you can save some $$).
https://onlineregistrations.ca/netdev21/

- hotel (If you can get the hotel cheaper online than conference
rates please send us email, dont book ):
https://www.netdevconf.org/2.1/hotel.html

3) Tech committee would like to make two announcements:

First, a talk by Hajime Tazaki titled "Playing BBR with a userspace 
network stack"

-----
Linux kernel library (LKL) is aimed to run Linux kernel code upon
different environment such as Linux userspace, Windows userspace,
hypervisors, etc.  With the userspace deployments, an application can
benefit new additional features such as TCP extensions without
involving the update of host kernel.

This characteristic of network stack personality is useful since we
don't have to instantiate a virtual machine instance to use a new
feature of network stack (e.g., a TCP extension).  Instead, we just
need a single (userspace) process to introduce new features.

One concern of userspace network stack in general, and addressed by
David Miller in the last netdev conference (in Tokyo), is the achieved
timing accuracy in userspace which the important network feature such
as packet pacing and transport protocols requires.

In this talk, we're going to present our performance studies on this
timing accuracy concern of a userspace network stack. We present the
result of netperf benchmarks with a couple of congestion control
algorithm of TCP, BBR and cubic with the LKL-ed netperf and ordinal
netperf with Linux kernel.
We're trying to reveal that what is the obstacle of LKL (userspace
network stack) and what can be fixed to reach the performance goal of
LKL (i.e., x1 performance of the original kernel network stack).

Second, our first workshop announcement on "IoT related MAC layers, header
compression and routing protocols" chaired by Stefan Schmidt.
---
This workshop aims to identify generic requirements for the networking
subsystem for IoT and starting the process of addressing the gaps
found. The workshop will encompass related MAC layers, networking
protocols, adaptation layers, header compression, routing protocols
and application layers.

As a starting point we will look at existing subsystems (Bluetooth,
802.15.4, 6LoWPAN, etc) and discuss a way forward to  address the gaps
posed. An overview of MAC layers and open IoT related specifications
will help to identify things we should probably support in the future
(LPWAN, SCHC, RPL, Thread, etc). Note: We emphasize only on open
protocols and specifications as well as IPv6 instead of company grown
networking layers.
Additional user-space interfaces might be needed to cater for the
requirements of application layer stacks (ZigBee, IoTivity, etc.).
What kind of interfaces besides the normal socket API and existing
netlink interfaces do they need?
(header compression configuration, DTLS support in AF_KTLS, etc.)

A primary goal of this workshop is initially to target Linux as a
gateway or border router at the edge of IoT networks, be it industrial
or home automation.

A future scope, starting with discussions at the workshop, could be for
Linux to replace RTOSes on leaf nodes which operate on very constrained
hardware and power limits; such an effort would need a serious amount
of work towards tinyfication in all parts of the kernel.

We expect the workshop to ignite efforts on these topics and followup
discussions on mailing lists and future netdevs to produce results that
make it a possibility.
----

cheers,
jamal
