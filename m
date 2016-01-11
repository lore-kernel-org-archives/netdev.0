From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/2] bpf: support ipv6 for bpf_skb_{set,get}_tunnel_key
Date: Mon, 11 Jan 2016 02:01:49 +0100
Message-ID: <5692FEFD.4030706@iogearbox.net>
References: <cover.1452385316.git.daniel@iogearbox.net> <cd5fc9d4b8de9a804923b3a96bbc0809473d35ff.1452385316.git.daniel@iogearbox.net> <20160111003507.GB21834@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, tgraf@suug.ch, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56215 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757375AbcAKBBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 20:01:53 -0500
In-Reply-To: <20160111003507.GB21834@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/11/2016 01:35 AM, Alexei Starovoitov wrote:
[...]
> was hoping that you would mention that people should upgrade
> their llvm to 3.7 release or later, since old pre-release
> had a bug when dealing with such structs and some
> 'lazy' folks may still be running some old version ;)

Thanks for mentioning. Had a pre 3.7 release git checkout of
LLVM locally ;), going for an official release had no issue.

> btw, three minor bugs were fixed after 3.7 was released.
> llvm 3.7.1 and 3.8 have no known issues in bpf backend.
