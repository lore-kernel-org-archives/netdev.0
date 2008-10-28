From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] net: don't use INIT_RCU_HEAD
Date: Tue, 28 Oct 2008 18:43:41 +0300
Message-ID: <20081028154341.GA22583@x200.localdomain>
References: <20081028133124.GA3006@x200.localdomain> <49072FC2.8030801@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.178]:36612 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966AbYJ1PkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 11:40:18 -0400
Received: by ik-out-1112.google.com with SMTP id c29so829175ika.5
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 08:40:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <49072FC2.8030801@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 28, 2008 at 04:29:06PM +0100, Patrick McHardy wrote:
> Alexey Dobriyan wrote:
>> call_rcu() will unconditionally rewrite RCU head anyway.
>> Applies to 	struct neigh_parms
>> 	struct neigh_table
>> 	struct net
>> 	struct cipso_v4_doi
>> 	struct in_ifaddr
>> 	struct in_device
>> 	rt->u.dst
>
> It would probably make sense to get a statement from Paul
> whether this might be required in the future, f.i. for some
> debugging feature.

Let's cc him :-)
