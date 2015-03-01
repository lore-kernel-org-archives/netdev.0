From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 3/6] flow_dissector: Add hash_extra field to
 flow_keys struct
Date: Sun, 1 Mar 2015 20:43:48 +0100
Message-ID: <20150301194348.GB23622@breakpoint.cc>
References: <1425093109-1077-1-git-send-email-therbert@google.com>
 <1425093109-1077-4-git-send-email-therbert@google.com>
 <1425109054.5130.77.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150228203119.GA7687@breakpoint.cc>
 <CA+mtBx8zP0rDG1Dh=KcG0t5dqaqnqS+8---4SBvLD_jGpgue2g@mail.gmail.com>
 <20150301182425.GA23622@breakpoint.cc>
 <CA+mtBx_9SKncJ1hfKj9icJP8bFbSKrHijeJoFOm7dU5MdwejRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:51873 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751166AbbCATnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 14:43:53 -0500
Content-Disposition: inline
In-Reply-To: <CA+mtBx_9SKncJ1hfKj9icJP8bFbSKrHijeJoFOm7dU5MdwejRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <therbert@google.com> wrote:
> We still need hash perturbation for the mapping to a small number of
> queues which can be done after retrieving skb_get_hash, but the
> probability that two different flows match perfectly in skb_get_hash()
> should be 1/2^32-- so are hash collisions really a concern here?

I'm not concerned about accidental collisions, how predictable is skb_get_hash()?
Is skb_get_hash() guaranteed to e.g. contain L4 information?

AFAIK answer to both is "depends on nic/driver", so I feel its better to use
software flow dissector.
