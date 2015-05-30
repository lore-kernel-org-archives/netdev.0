From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: add missing rcu protection when releasing
 programs from prog_array
Date: Sat, 30 May 2015 11:02:32 +0200
Message-ID: <55697CA8.2010606@iogearbox.net>
References: <1432866362-8154-1-git-send-email-ast@plumgrid.com> <55682D1C.3070607@iogearbox.net> <5568F4C3.5010007@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46228 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757558AbbE3JCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2015 05:02:42 -0400
In-Reply-To: <5568F4C3.5010007@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/2015 01:22 AM, Alexei Starovoitov wrote:
...
> Like __sk_filter_release() and __bpf_prog_release() should be removed.

The whole filter cleanup procedure needs to be simplified a bit, got a
bit too complicated over time, agreed.

> Of course, it's a grey line when to introduce a helper and when not to,
> but just because two lines are close enough between two functions it
> doesn't mean that helper is warranted. In this bpf_prog_put() case
> I think helper is not needed _today_. If it grows, we'll reconsider.

Yes, that's what I meant.
