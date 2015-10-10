From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bpf, skb_do_redirect: clear sender_cpu before
 xmit
Date: Sat, 10 Oct 2015 10:12:05 -0700
Message-ID: <1444497125.27760.122.camel@edumazet-glaptop2.roam.corp.google.com>
References: <ceae3b812d3e01f73efcfdff0a7817b3c61ae24e.1444205375.git.daniel@iogearbox.net>
	 <56153E6C.9050202@plumgrid.com>
	 <CADe=ujYvfU_h46cQXiG6Vt1iZfs+A7fYqeZ_vWtob2Kef08ukQ@mail.gmail.com>
	 <561727D5.2070001@plumgrid.com> <5617FA5A.9090406@iogearbox.net>
	 <561883CB.4030808@plumgrid.com>
	 <1444451914.27760.116.camel@edumazet-glaptop2.roam.corp.google.com>
	 <56189A67.6080109@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	"Devon H. O'Dell" <dho@fastly.com>, davem@davemloft.net,
	edumazet@google.com, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36156 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485AbbJJRMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 13:12:07 -0400
Received: by pablk4 with SMTP id lk4so115309282pab.3
        for <netdev@vger.kernel.org>; Sat, 10 Oct 2015 10:12:07 -0700 (PDT)
In-Reply-To: <56189A67.6080109@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-10-09 at 21:56 -0700, Alexei Starovoitov wrote:

> yep. as I said it shouldn't be increased and proposed in-band sign bit.

I believe we still would like to keep some helpers to clearly identify
when a packet crosses domains. Even if the helper is empty.

It helps a lot when a new feature must be added.

skb_scrub_packet() and similar helper are not only doing useful work,
they are easily grep-able.

So your idea sounds nice, but in reality it maintains the status quo,
where we do not really know which points need care when skbs cross a
domain.
