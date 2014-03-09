From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG?] ixgbe: only num_online_cpus() of the tx queues are
 enabled
Date: Sun, 09 Mar 2014 06:39:46 -0700
Message-ID: <1394372386.20149.88.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAG+wggZOQ_VyAiLBuUUfW13=OqUun3g1vnYj5SEuWN+3hHreLg@mail.gmail.com>
	 <1394292461.20149.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1394294883.20149.70.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAG+wggbNpUqL12EAWdXxxxX6mGPj0+1HktDKJeeSxum6emBY_g@mail.gmail.com>
	 <1394336258.20149.80.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAG+wggY24+mc=8bCyr3fB+H7DJNfjANQuqbuDRcdUd9=+ip-Ew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Erez Zadok <ezk@fsl.cs.sunysb.edu>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Geoff Kuenning <geoff@cs.hmc.edu>
To: Ming Chen <v.mingchen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:61152 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209AbaCINjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 09:39:48 -0400
Received: by mail-pb0-f52.google.com with SMTP id rr13so6143858pbb.25
        for <netdev@vger.kernel.org>; Sun, 09 Mar 2014 06:39:47 -0700 (PDT)
In-Reply-To: <CAG+wggY24+mc=8bCyr3fB+H7DJNfjANQuqbuDRcdUd9=+ip-Ew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-03-09 at 01:47 -0500, Ming Chen wrote:

> Thanks for the patch. I forgot to mention that excessively big cwnd
> (or bufferbloat) does play a part in Hash-Cast. We found that using
> TCP Vegas does not show unfairness even in the presence of hash
> collision among TCP flows. Comparing Vegas and Cubic, we found that
> Vegas has a much smaller cwnd.

Of course, Vegas is delay based. It does not need to increase cwnd to
insane values.

Problem is it does not compete well in presence of non Vegas flows.

And unfortunately, Internet is filled by non Vegas flows.
