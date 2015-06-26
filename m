From: Ajith Adapa <adapa.ajith@gmail.com>
Subject: Re: Issue with LACP mode support in Linux bonding driver
Date: Fri, 26 Jun 2015 07:07:09 +0530
Message-ID: <CADAe=+LV=qxt1fwxJdvz6ODScDGGUpmA0YE+mPKZE4C2X0sqUA@mail.gmail.com>
References: <CADAe=+LERY5jgVLpVdteFQXhcJdHzNxJpj=9t7Nyf0YTmSXcYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:33301 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbbFZBhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 21:37:50 -0400
Received: by oiyy130 with SMTP id y130so65547169oiy.0
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 18:37:49 -0700 (PDT)
In-Reply-To: <CADAe=+LERY5jgVLpVdteFQXhcJdHzNxJpj=9t7Nyf0YTmSXcYQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

How can I know the current maintainer for Linux Bonding Driver ?

Regards,
Ajith

Regards,
Ajith
--------------------------------------------
codingfreak.blogspot.com


On 24 June 2015 at 15:25, Ajith Adapa <adapa.ajith@gmail.com> wrote:
> Hi,
>
> I am using Centos7 with v3.10 kernel.
>
> My issue is related to multiaggregation in LACP.
>
> In my setup topology I connected linux server and a L2 switch back to
> back with 2 interfaces eth0 and eth1 (on both sides).
>
> On Switch I have mapped eth0 to po1 and eth1 to po2. On linux server I
> have created a single bond interface with both interfaces eth0 and
> eth1.
>
> On L2 switch both po1 and po2 has same system-id but the Actor key is
> different i.e. on PO1 it is 16385 and on PO2 it is 32768. As per the
> information available about bond0 on linux server which is given below
> Active aggregator ID is 1 which is mapped to eth0 but eth1.
>
> But we have observed that eth1 on linux server is also sending LACPDUS
> with Collecting/Distributing bit set as 1. Which will result in single
> bond interface on Linux server is splitted into multiple port-channels
> on Switch causing duplication of frames on linux server.
>
> As per IEEE 802.3ad 2003 standard portchannel should not support
> multi-aggregation.
>
>
> #  cat /proc/net/bonding/bond0
> Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
>
> Bonding Mode: IEEE 802.3ad Dynamic link aggregation
> Transmit Hash Policy: layer2 (0)
> MII Status: up
> MII Polling Interval (ms): 100
> Up Delay (ms): 0
> Down Delay (ms): 0
>
> 802.3ad info
> LACP rate: fast
> Min links: 0
> Aggregator selection policy (ad_select): stable
> Active Aggregator Info:
>     Aggregator ID: 1
>     Number of ports: 1
>     Actor Key: 17
>     Partner Key: 16385
>     Partner Mac Address: 11:11:22:22:33:33
>
> Slave Interface: eth0
> MII Status: up
> Speed: 1000 Mbps
> Duplex: full
> Link Failure Count: 0
> Permanent HW addr: 08:00:27:18:ae:4b
> Aggregator ID: 1
> Slave queue ID: 0
>
> Slave Interface: eth1
> MII Status: up
> Speed: 1000 Mbps
> Duplex: full
> Link Failure Count: 0
> Permanent HW addr: 08:00:27:76:35:a2
> Aggregator ID: 3
> Slave queue ID: 0
>
>
> Regards,
> Ajith
