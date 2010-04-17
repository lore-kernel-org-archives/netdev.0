From: Tom Herbert <therbert@google.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Sat, 17 Apr 2010 10:26:14 -0700
Message-ID: <m2o65634d661004171026v5473b1f4yaa4fdfdd05293649@mail.gmail.com>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <4BC741AE.3000108@hp.com> <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
	 <1271395106.16881.3645.camel@edumazet-laptop>
	 <1271424065.4606.31.camel@bigi>
	 <1271489739.16881.4586.camel@edumazet-laptop>
	 <z2q65634d661004170143nb35ec784mbedd003565410cfb@mail.gmail.com>
	 <1271496229.16881.4602.camel@edumazet-laptop>
	 <1271514445.16881.4746.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: hadi@cyberus.ca, Changli Gao <xiaosuo@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	robert@herjulf.net, andi@firstfloor.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:15299 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748Ab0DQR0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Apr 2010 13:26:19 -0400
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o3HHQGG0025412
	for <netdev@vger.kernel.org>; Sat, 17 Apr 2010 19:26:17 +0200
Received: from pwj4 (pwj4.prod.google.com [10.241.219.68])
	by wpaz5.hot.corp.google.com with ESMTP id o3HHQF66013834
	for <netdev@vger.kernel.org>; Sat, 17 Apr 2010 10:26:15 -0700
Received: by pwj4 with SMTP id 4so2691211pwj.36
        for <netdev@vger.kernel.org>; Sat, 17 Apr 2010 10:26:15 -0700 (PDT)
In-Reply-To: <1271514445.16881.4746.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Tom, I am not sure what you describe is even respected for NAPI devices.
> (I hope you use napi devices in your company ;) )
>
> If we enqueue a skb to backlog, we also link our backlog napi into our
> poll_list, if not already there.
>
> So the loop in net_rx_action() will make us handle our backlog napi a
> bit after this network device napi (if time limit of 2 jiffies not
> elapsed) and *before* sending IPIS to remote cpus anyway.
>
Then I think that's a bug you've identified ;-)

>
>
>
>
