From: Geoff Kuenning <geoff@cs.hmc.edu>
Subject: Re: [BUG?] ixgbe: only num_online_cpus() of the tx queues are enabled
Date: Mon, 10 Mar 2014 21:56:31 -0700
Message-ID: <pnizjkxxri8.fsf@bow.cs.hmc.edu>
References: <CAG+wggZOQ_VyAiLBuUUfW13=OqUun3g1vnYj5SEuWN+3hHreLg@mail.gmail.com>
	<1394292461.20149.55.camel@edumazet-glaptop2.roam.corp.google.com>
	<1394294883.20149.70.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAG+wggbNpUqL12EAWdXxxxX6mGPj0+1HktDKJeeSxum6emBY_g@mail.gmail.com>
	<1394336258.20149.80.camel@edumazet-glaptop2.roam.corp.google.com>
	<531BE567.3040101@gmail.com>
	<CAG+wggY+Ya1ehtAF9ZF=wkq7aQ9jgsQOB-Nj0ZwQhJWTMs3PQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Erez Zadok <ezk@fsl.cs.sunysb.edu>,
	Dean Hildebrand <dhildeb@us.ibm.com>
To: Ming Chen <v.mingchen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mallet.cs.hmc.edu ([134.173.42.59]:41293 "EHLO
	mallet.cs.hmc.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752504AbaCKFFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 01:05:20 -0400
In-Reply-To: <CAG+wggY+Ya1ehtAF9ZF=wkq7aQ9jgsQOB-Nj0ZwQhJWTMs3PQA@mail.gmail.com>
	(Ming Chen's message of "Sun, 9 Mar 2014 01:56:18 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> In our case, we believe larger number of tx queues will reduce the
> probability of hash collision.

However, that's only true for fairly small numbers of flows.  If you
have 64 queues and 65 flows then two of the flows are guaranteed to
collide in the best case.

Not that I have a brilliant solution, just pointing it out...
-- 
    Geoff Kuenning   geoff@cs.hmc.edu   http://www.cs.hmc.edu/~geoff/

Orchestra retrospectively extremely satisfied with symphony [No. 1] as
result of barrel of free beer.
	-- Gustav Mahler, post-premiere letter to Arnold Berliner
