From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: adjust verifier heuristics
Date: Thu, 18 May 2017 12:34:58 +0200
Message-ID: <591D78D2.6080004@iogearbox.net>
References: <57a6fc1f937d985a5851016221c98a29fb1cc46a.1495068621.git.daniel@iogearbox.net> <20170517.225637.2083628580374404255.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36843 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752689AbdERKfF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 06:35:05 -0400
In-Reply-To: <20170517.225637.2083628580374404255.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/18/2017 04:56 AM, David Miller wrote:
[...]
> Ok, applied, but we should continue trying to make the pruner
> more effective.

Yeah, agree, I was planning to look into states_equal() for
the current alignment tracking we do and what we can optimize
resp. what needs to be fixed there on pruning side for -net
tree with regards to my prior mail on that. If you haven't
started, I could look into this next Monday at latest.

Thanks,
Daniel
