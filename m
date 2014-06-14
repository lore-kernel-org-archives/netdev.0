From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: No GSOs to i40e with VXLAN
Date: Fri, 13 Jun 2014 19:33:40 -0700
Message-ID: <1402713220.3645.506.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.LFD.2.11.1406131657240.4926@fvl-a0.jf.intel.com>
	 <CA+mtBx_6BWhHm4eK2qqR737jwQHi_dyrv-Md_-_f5AEghWNAKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:47099 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811AbaFNCdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2014 22:33:41 -0400
Received: by mail-pb0-f47.google.com with SMTP id un15so2680381pbc.34
        for <netdev@vger.kernel.org>; Fri, 13 Jun 2014 19:33:41 -0700 (PDT)
In-Reply-To: <CA+mtBx_6BWhHm4eK2qqR737jwQHi_dyrv-Md_-_f5AEghWNAKg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-06-13 at 18:59 -0700, Tom Herbert wrote:

> I verified tunnel offload works properly with bnx2x (I'm using simple
> vxlan interfaces not OVS).
> 
> One possibility I can think of is that UDP checksums are somehow
> enabled. If you're using IPv6 this probably the case (but I assume
> you're seeing this with IPv4). If checksums are inadvertently enabled
> somehow in IPv4 this should should up in tcpdump on the Ethernet
> interface.

Tom, I have a pair of hosts with i40e NIC, I can give you access to.
