From: Ming Chen <v.mingchen@gmail.com>
Subject: Re: [BUG?] ixgbe: only num_online_cpus() of the tx queues are enabled
Date: Sun, 9 Mar 2014 01:56:18 -0500
Message-ID: <CAG+wggY+Ya1ehtAF9ZF=wkq7aQ9jgsQOB-Nj0ZwQhJWTMs3PQA@mail.gmail.com>
References: <CAG+wggZOQ_VyAiLBuUUfW13=OqUun3g1vnYj5SEuWN+3hHreLg@mail.gmail.com>
	<1394292461.20149.55.camel@edumazet-glaptop2.roam.corp.google.com>
	<1394294883.20149.70.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAG+wggbNpUqL12EAWdXxxxX6mGPj0+1HktDKJeeSxum6emBY_g@mail.gmail.com>
	<1394336258.20149.80.camel@edumazet-glaptop2.roam.corp.google.com>
	<531BE567.3040101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Erez Zadok <ezk@fsl.cs.sunysb.edu>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Geoff Kuenning <geoff@cs.hmc.edu>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:64492 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761AbaCIG4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 01:56:18 -0500
Received: by mail-ie0-f178.google.com with SMTP id lx4so6120267iec.9
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2014 22:56:18 -0800 (PST)
In-Reply-To: <531BE567.3040101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 8, 2014 at 10:52 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
>
> The NIC by default will round robin amongst the queues and should be
> reasonably fair. We could increase the number of TX queues the driver
> enables and for a small number of flows the first condition is easier
> to meet. Although it wont help as the flow count increases.

Yes, it is definitely better to be capable of using all tx queues.
>From a customer's point of view, if someone bought an NIC with 64
queues, then the vendor (and the NIC driver) should enable him/her to
use all queues if the customer really want to.

In our case, we believe larger number of tx queues will reduce the
probability of hash collision.

Thanks,
Ming
