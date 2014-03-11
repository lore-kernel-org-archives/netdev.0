From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH RFC 0/9] socket filtering using nf_tables
Date: Tue, 11 Mar 2014 05:57:39 -0700
Message-ID: <871ty8hozg.fsf@tassilo.jf.intel.com>
References: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, kaber@trash.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61304 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751986AbaCKM5r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2014 08:57:47 -0400
In-Reply-To: <1394529560-3490-1-git-send-email-pablo@netfilter.org> (Pablo
	Neira Ayuso's message of "Tue, 11 Mar 2014 10:19:11 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso <pablo@netfilter.org> writes:

> The following patchset provides a socket filtering alternative to BPF
> which allows you to define your filter using the nf_tables expressions.
>
> Similarly to BPF, you can attach filters via setsockopt()
> SO_ATTACH_NFT_FILTER. The filter that is passed to the kernel is
> expressed in netlink TLV format which looks like:

Could you explain how you validted and tested the nf engine to make it safe for
non root without any security problems?

-andi 

-- 
ak@linux.intel.com -- Speaking for myself only
