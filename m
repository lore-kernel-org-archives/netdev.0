From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH RFC 00/24] IPVS: Add first IPv6 support to IPVS
Date: Thu, 21 Aug 2008 11:59:44 +0200
Message-ID: <f4845fc0808210259n2b4bbd41tb0a93c49592a2029@mail.gmail.com>
References: <1219248931-15064-1-git-send-email-juliusv@google.com>
	 <20080821011715.GG19235@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org, kaber@trash.net,
	vbusam@google.com, "Sven Wegener" <sven.wegener@stealer.net>
To: "Simon Horman" <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:55639 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031AbYHUJ7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 05:59:53 -0400
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out3.google.com with ESMTP id m7L9xlB8021690
	for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 10:59:47 +0100
Received: from ug-out-1314.google.com (ugem2.prod.google.com [10.66.164.2])
	by wpaz17.hot.corp.google.com with ESMTP id m7L9xjQh022136
	for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 02:59:46 -0700
Received: by ug-out-1314.google.com with SMTP id m2so1462922uge.17
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 02:59:45 -0700 (PDT)
In-Reply-To: <20080821011715.GG19235@verge.net.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 3:17 AM, Simon Horman <horms@verge.net.au> wrote:
> On Wed, Aug 20, 2008 at 06:15:07PM +0200, Julius Volz wrote:
>> What is not supported with IPv6:
>> - handling fragmentation or other extension headers
>> - FTP application helper (can be loaded, but only operates on v4)
>> - sync daemon (can be started, but only operates on v4)
>
> Other than the packet format of the sync deamon, are there any
> fundamental restrictions here? If we extended the sync daemon,
> could it work? If so, perhaps we could rev the sync deamon protocol
> and fix a few other kinks, like the handling of timeouts and the
> general lack of extendability, at the same time.

There shouldn't be any fundamental restrictions, it's just a piece of
the puzzle that I could easily leave out of the picture for now.

I haven't studied the sync daemon closely yet, but one thing I was
briefly wondering about was whether we should just blow up the
addresses in struct ip_vs_sync_conn to be of type union nf_inet_addr
(probably not acceptable, wasting too much bandwidth for v4 entries)
or how to send differently sized entries based on the IP version in a
clean way. But it sounds like you'd want to redesign a lot of that
anyways? I'm glad to help with anything, I just don't know this code
as well as you or Sven, but I'll study it more. Maybe you can share
some ideas on the extensibility you want to see?

>> Thanks for any comments!
>
> Unfortunately (or fortunately depending on how you look at it),
> I'm going to be away skiing for the next couple of days. Apologies
> for the slow responses that will lead to.

Have fun! And be careful, we need you to come back healthy :)

Julius

-- 
Google Switzerland GmbH
