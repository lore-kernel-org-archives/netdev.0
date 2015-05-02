From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v3 net-next] pktgen: introduce 'rx' mode
Date: Sat, 02 May 2015 11:44:45 +0200
Message-ID: <55449C8D.4020902@iogearbox.net>
References: <1430457130-16003-1-git-send-email-ast@plumgrid.com> <20150502104621.4fede885@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Robert Olsson <robert@herjulf.net>,
	Ben Greear <greearb@candelatech.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39124 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbbEBJo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2015 05:44:57 -0400
In-Reply-To: <20150502104621.4fede885@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesper,

On 05/02/2015 10:46 AM, Jesper Dangaard Brouer wrote:
...
> First of all I love the idea of modifying pktgen to performance test
> the RX path.
>
> I'm not sure the simple "rx" flag is a good "name".  It likely
> conflicts with other work where pktgen can receive it own packets, e.g.
> https://people.kth.se/~danieltt/pktgen/ or Ben Greer's solution.

Why do we start caring about out of tree code now? We never have,
really. If there is no interest in merging this stuff upstream,
then it's always the case that _their code_ needs to adapt iff you
want to run on a more recent kernel; the kernel dictates the uapi,
not some out of tree module. ;)

Cheers,
Daniel
