From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next 0/2] handle_ing update
Date: Mon, 11 May 2015 15:48:14 -0700
Message-ID: <CAHA+R7OH2moexqvJMHG-Mhu16ycp0n7J3B4wHPbrEt-GPY5=Ag@mail.gmail.com>
References: <cover.1431203900.git.daniel@iogearbox.net>
	<20150510170550.GA4442@salvia>
	<20150511.110949.1369224056076525434.davem@davemloft.net>
	<CAHA+R7Od3WWS+sM0cr7=4YEB4qMiY61dfrfH_+Eeayi=LxzEsw@mail.gmail.com>
	<55512E39.2010203@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:38226 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751858AbbEKWsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 18:48:15 -0400
Received: by wiun10 with SMTP id n10so115734297wiu.1
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 15:48:14 -0700 (PDT)
In-Reply-To: <55512E39.2010203@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 11, 2015 at 3:33 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 05/12/2015 12:03 AM, Cong Wang wrote:
> ...
>>
>> BTW, it should be protected by CONFIG_NET_SCH_INGRESS
>> rather than CONFIG_NET_CLS_ACT.
>
>
> Sure, I agree, this can further be improved. Feel free to send a patch.

I never agree on that approach, it makes the code even messy,
less readable. Correctness and readability are much more important
than a little performance gain, for me, not for you of course.
