From: Devendra C <devendra-stark@outlook.com>
Subject: RE: kernel BUG at /build/buildd/linux-2.6.32/mm/mempolicy.c
Date: Wed, 5 Dec 2012 22:16:02 +0530
Message-ID: <COL002-W107B8681F385DB3959EF1DD85460@phx.gbl>
References: <50BF66A0.1050503@eml.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Bokhan Artem <art@eml.ru>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Borislav Petkov (" <bp@alien8.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50BF66A0.1050503@eml.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Date: Wed, 5 Dec 2012 22:22:08 +0700
> From: art@eml.ru
> To: linux-kernel@vger.kernel.org
> Subject: kernel BUG at /build/buildd/linux-2.6.32/mm/mempolicy.c
> 
> Hello.
> 
> We have several servers with mongodb running. Each server has several mongodb 
> instances. Mongodb dataset is larger then availiable memory (mongodb uses 
> memory-mapped files for all disk I/O).
> 2.6.32 and 2.6.38 kernels periodically crash and crash happens only with mongodb 
> servers.
> 
> 2.6.38's trace is in attachment.
> For 2.6.32 I only have "kernel BUG at 
> /build/buildd/linux-2.6.32/mm/mempolicy.c:1489!"
> 
> Heed help! :)

Adding netdev to cc,

seems like the networking bug?

if so please attach some tcpdump traces, lspci -vv -n, 

please forgive me if its not related to networking. :(

thanks, 		 	   		  