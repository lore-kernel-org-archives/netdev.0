From: jamal <hadi@cyberus.ca>
Subject: Re: Routing 600+ vlan's via linux problems (looks like arp
	problems)
Date: Thu, 03 May 2007 20:01:38 -0400
Message-ID: <1178236898.4068.47.camel@localhost>
References: <d20c3b7d0705031325r13834382r38ea31f26965c50@mail.gmail.com>
	 <20070503205346.GD18539@uranus.ravnborg.org>
	 <20070503143832.17a08fbb@freekitty>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Sam Ravnborg <sam@ravnborg.org>,
	=?ISO-8859-1?Q?=D8yvind_V=E5gen_J=E6gtnes?= <lorrides@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:44128 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767473AbXEDABo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 20:01:44 -0400
Received: by wx-out-0506.google.com with SMTP id h31so598713wxd
        for <netdev@vger.kernel.org>; Thu, 03 May 2007 17:01:43 -0700 (PDT)
In-Reply-To: <20070503143832.17a08fbb@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-03-05 at 14:38 -0700, Stephen Hemminger wrote:

> What kernel version?  Are you on a recent 2.6 kernel or stuck on some 
> old "vendor stable" 2.4 kernel?

VendorStable(tm)?;->

Sounds to me like an ARP gc challenge to me.
If it is, it would help incrementing the values in  
/proc/sys/net/ipv4/neigh/default/gc_thresh*

Try multiplying by some factor like 5 to see what happens i.e
---
hadi@lilsol:~$ cat /proc/sys/net/ipv4/neigh/default/gc_thresh1
128
---

Make that 640 and repeat multiplying by 5 all the other thresholds

cheers,
jamal

PS:- As usual i took lkml off the list

