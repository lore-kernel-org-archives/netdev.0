From: Ming Chen <v.mingchen@gmail.com>
Subject: Re: [BUG?] ixgbe: only num_online_cpus() of the tx queues are enabled
Date: Sun, 9 Mar 2014 15:22:21 -0400
Message-ID: <CAG+wgga4fYOS=V6YHVNpYiu5RgqSEJ5qbM4XaPFdTUnYmhHaog@mail.gmail.com>
References: <CAG+wggZOQ_VyAiLBuUUfW13=OqUun3g1vnYj5SEuWN+3hHreLg@mail.gmail.com>
	<1394292461.20149.55.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAG+wggaUHeD5Vm_HF9m4+1SZZOUo_GeQroM+0kyA_qTC5c8=3Q@mail.gmail.com>
	<1394335754.20149.73.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAG+wggY=5BWaDujaiP6hnD5vTsXiOBNqBDYnqjEW_F4fdaMOyw@mail.gmail.com>
	<1394372662.20149.92.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Erez Zadok <ezk@fsl.cs.sunysb.edu>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Geoff Kuenning <geoff@cs.hmc.edu>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:45978 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812AbaCITWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 15:22:21 -0400
Received: by mail-ig0-f179.google.com with SMTP id t19so6522603igi.0
        for <netdev@vger.kernel.org>; Sun, 09 Mar 2014 12:22:21 -0700 (PDT)
In-Reply-To: <1394372662.20149.92.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric and John,

I could not get the command working:

#ethtool -l p3p1
Channel parameters for p3p1:
Pre-set maximums:
RX:             0
TX:             0
Other:          1
Combined:       63
Current hardware settings:
RX:             0
TX:             0
Other:          1
Combined:       6

#ethtool -L p3p1 rx 1 tx 1
Cannot set device channel parameters: Invalid argument

#ethtool -L p3p1 rx 1 tx 1 other 1
other unmodified, ignoring
Cannot set device channel parameters: Invalid argument

Best,
Ming

On Sun, Mar 9, 2014 at 9:44 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> If you want to use a single queue, just declare a single queue on your
> NIC...
>
> ethtool -L eth0 rx 1 tx 1
>
> Multiqueue is not a requirement in your case. You can easily reach line
> rate with a single queue on a 10Gbe NIC.
>
>
>
