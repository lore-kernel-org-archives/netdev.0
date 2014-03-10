From: Ming Chen <v.mingchen@gmail.com>
Subject: Re: [BUG?] ixgbe: only num_online_cpus() of the tx queues are enabled
Date: Mon, 10 Mar 2014 01:40:23 -0400
Message-ID: <CAG+wggaPSfSiaTj6qPtOS3xnWRVrOa9+NA72YyQ8bXwB0i6SPg@mail.gmail.com>
References: <CAG+wggZOQ_VyAiLBuUUfW13=OqUun3g1vnYj5SEuWN+3hHreLg@mail.gmail.com>
	<1394292461.20149.55.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAG+wggaUHeD5Vm_HF9m4+1SZZOUo_GeQroM+0kyA_qTC5c8=3Q@mail.gmail.com>
	<1394335754.20149.73.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAG+wggY=5BWaDujaiP6hnD5vTsXiOBNqBDYnqjEW_F4fdaMOyw@mail.gmail.com>
	<1394372662.20149.92.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, Erez Zadok <ezk@fsl.cs.sunysb.edu>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Geoff Kuenning <geoff@cs.hmc.edu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:60956 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751873AbaCJFkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 01:40:23 -0400
Received: by mail-ie0-f174.google.com with SMTP id rp18so6774696iec.33
        for <netdev@vger.kernel.org>; Sun, 09 Mar 2014 22:40:23 -0700 (PDT)
In-Reply-To: <1394372662.20149.92.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 9, 2014 at 9:44 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Multiqueue is not a requirement in your case. You can easily reach line
> rate with a single queue on a 10Gbe NIC.
>

I repeated the experiment for 10 times using one tx queue with FQ, and
all clients get fair share of the bandwidth. The overall throughout
showed no difference between the single queue case and the mq case,
and the throughput in both cases are close to the line rate.

Thanks,
Ming
