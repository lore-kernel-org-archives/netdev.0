From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] net: sched: fix refcount imbalance in actions
Date: Thu, 30 Jul 2015 22:01:57 +0200
Message-ID: <55BA82B5.4070602@iogearbox.net>
References: <00f17fd2908b742c7e450bb76a1d487c0b32304f.1438205044.git.daniel@iogearbox.net>	<CAHA+R7MVFhv1_J=0QE6zjCiVtCCKsaU=WgX6eH-u3op7GLZW5w@mail.gmail.com>	<55B9760B.10004@iogearbox.net> <CAHA+R7NOZadKESRmSZpWxmdG9wRg+15cHbc5H_zUgp77zofPZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46096 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbbG3UCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 16:02:02 -0400
In-Reply-To: <CAHA+R7NOZadKESRmSZpWxmdG9wRg+15cHbc5H_zUgp77zofPZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/30/2015 08:48 PM, Cong Wang wrote:
...
> Right, I think your patch should be fine for net. The code is kinda messy,
> but we can always clean up the logic for net-next.

I agree with you. I.e. there could just be a single refcount taking care
of the cleanup/destruction, etc.

> Reviewed-by: Cong Wang <cwang@twopensource.com>
>
> (It looks like mirred doesn't handle bind == true case correctly, I will send a
> separated for it after your patch.)

Okay. Thanks for the review Cong!

Cheers,
Daniel
