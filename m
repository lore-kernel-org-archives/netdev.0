From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 0/2] handle_ing update
Date: Tue, 12 May 2015 00:33:29 +0200
Message-ID: <55512E39.2010203@iogearbox.net>
References: <cover.1431203900.git.daniel@iogearbox.net>	<20150510170550.GA4442@salvia>	<20150511.110949.1369224056076525434.davem@davemloft.net> <CAHA+R7Od3WWS+sM0cr7=4YEB4qMiY61dfrfH_+Eeayi=LxzEsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60124 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414AbbEKWde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 18:33:34 -0400
In-Reply-To: <CAHA+R7Od3WWS+sM0cr7=4YEB4qMiY61dfrfH_+Eeayi=LxzEsw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/12/2015 12:03 AM, Cong Wang wrote:
...
> BTW, it should be protected by CONFIG_NET_SCH_INGRESS
> rather than CONFIG_NET_CLS_ACT.

Sure, I agree, this can further be improved. Feel free to send a patch.

>> I also am confident that the cost for non-users is equivalent before
>> and after this patch series.  Or at least, it very much should be.
>
> If people really cared about ingress qdisc, that spinlock should have
> gone much earlier than in 4.x release, rather than waiting for me to
> remind.

Thanks for your reminder then. ;)

Cheers,
Daniel
