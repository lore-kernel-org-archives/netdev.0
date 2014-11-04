From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH net] vxlan: Do not reuse sockets for a different address
 family
Date: Tue, 04 Nov 2014 14:56:33 -0200
Message-ID: <54590541.8050308@redhat.com>
References: <b2c5c4c68f0ae715802b4b4fd35fd1031c65aac0.1415108561.git.mleitner@redhat.com> <20141104.113203.432907272611801931.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	sergei.shtylyov@cogentembedded.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32963 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750819AbaKDQ4i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 11:56:38 -0500
In-Reply-To: <20141104.113203.432907272611801931.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04-11-2014 14:32, David Miller wrote:
> From: Marcelo Ricardo Leitner <mleitner@redhat.com>
> Date: Tue,  4 Nov 2014 11:46:49 -0200
>
>>   	hlist_for_each_entry_rcu(vs, vs_head(net, port), hlist) {
>> -		if (inet_sk(vs->sock->sk)->inet_sport == port)
>> +		if ((inet_sk(vs->sock->sk)->inet_sport == port) &&
>> +			(inet_sk(vs->sock->sk)->sk.sk_family == family))
>
> This is not indented properly.
>
> For a multi-line conditional, the second and subsequent lines
> should start precisely at the first column after the openning
> parenthesis on the first line.
>
> You must use the appropriate number of TAB and SPACE characters
> necessary to achieve this.  If you are only using TAB characters, you
> are most likely doing it wrong.

Yes.. I forgot to switch profiles, was using tab spacing=4, then it was 
aligned and I didn't notice it.

> Please fix this up and resubmit, thanks.

Okay, sorry. Thanks David, Sergei.

Marcelo
