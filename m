From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 0/2] handle_ing update
Date: Mon, 11 May 2015 15:23:57 -0700
Message-ID: <55512BFD.3070400@plumgrid.com>
References: <cover.1431203900.git.daniel@iogearbox.net>	<20150510170550.GA4442@salvia>	<20150511.110949.1369224056076525434.davem@davemloft.net> <CAHA+R7Od3WWS+sM0cr7=4YEB4qMiY61dfrfH_+Eeayi=LxzEsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35284 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889AbbEKWX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 18:23:59 -0400
Received: by pabtp1 with SMTP id tp1so120479920pab.2
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 15:23:59 -0700 (PDT)
In-Reply-To: <CAHA+R7Od3WWS+sM0cr7=4YEB4qMiY61dfrfH_+Eeayi=LxzEsw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/11/15 3:03 PM, Cong Wang wrote:
> On Mon, May 11, 2015 at 8:09 AM, David Miller <davem@davemloft.net> wrote:
>> There is no difference between having ingress qdisc hanging off of
>> netdevice vs. the classifier list.  They both serve the same purpose
>> and the change to use the classifier list merely removes one level
>> of indirection.
>
> With adding 8 bytes to each of the netdevice even when it doesn't
> have ingress qdisc attached at all...

we already said several times that the work is already on the way
to remove 'ingress_queue' from net_device. It will save much more
memory than addition of 8 bytes.
