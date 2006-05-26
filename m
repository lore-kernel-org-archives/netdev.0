From: Andi Kleen <ak@suse.de>
Subject: Re: Netfilter and SMP
Date: Fri, 26 May 2006 19:52:50 +0200
Message-ID: <200605261952.50755.ak@suse.de>
References: <a656c20605260823o1c894411t88a76c23d7855406@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:30388 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1750782AbWEZR4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 13:56:13 -0400
To: "Majid Khan" <majidkk@gmail.com>
In-Reply-To: <a656c20605260823o1c894411t88a76c23d7855406@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Can somebody provide me with some information on how to configure my
> SMP system so that both processors share the network traffic load.

You would need multiple active incoming network interfaces. 
Linux right now doesn't support load balancing from a single interrupt.
Even if it did that would likely require hardware support for MSI-X.

> My second question was that if there is any known method to gracefully
> handle failures in a netfilter module. Currently any failure in
> netfilter would cause the kernel panic.

Write a user space module using nf queue? 

-Andi
 
