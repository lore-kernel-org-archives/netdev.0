From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] tc: fix tc actions in case of shared skb
Date: Tue, 14 Jul 2015 18:01:59 -0700
Message-ID: <55A5B107.7010703@plumgrid.com>
References: <55A41CE9.8050907@plumgrid.com> <55A425C4.60301@iogearbox.net>
 <55A43B26.1010009@plumgrid.com>
 <20150714.153422.914759715820927338.davem@davemloft.net>
 <55A59657.2050100@plumgrid.com> <55A5B027.70604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, jhs@mojatatu.com, jiri@resnulli.us,
	netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:32862 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426AbbGOBCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 21:02:02 -0400
Received: by pdbqm3 with SMTP id qm3so14638025pdb.0
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 18:02:01 -0700 (PDT)
In-Reply-To: <55A5B027.70604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/14/15 5:58 PM, John Fastabend wrote:
> Right and we hit this issue when pktgen is run over any stacked device
> with clone_skb set. I've always put it in the don't do this category but
> a fix would be nice.

hmm, are you sure that commit
52d6c8c6ca12 ("net: pktgen: disable xmit_clone on virtual devices")
didn't fix it already?
