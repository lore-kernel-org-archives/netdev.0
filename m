From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 net-next 1/6] sctp: add sctp_info dump api for
 sctp_diag
Date: Sat, 09 Apr 2016 10:21:47 -0700
Message-ID: <1460222507.6473.493.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1460177331.git.lucien.xin@gmail.com>
	 <c507274a984bd1b0a7e7a59d1e825352536efd25.1460177331.git.lucien.xin@gmail.com>
	 <1460178984.6473.473.camel@edumazet-glaptop3.roam.corp.google.com>
	 <57091D90.4030905@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>,
	linux-sctp@vger.kernel.org,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:35886 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753384AbcDIRVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 13:21:51 -0400
In-Reply-To: <57091D90.4030905@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-04-09 at 11:19 -0400, Jamal Hadi Salim wrote:
> On 16-04-09 01:16 AM, Eric Dumazet wrote:
> 
> >
> > Lots of holes in this structure...
> >
> >
> 
> 
> I may have mentioned to you that there is 8 bit hole in tcp_info too ;->
> (above tcpi_rto). Adding an 8 bit explicit pad seems useful
> since it is already in the wild. I was going to send the patch after
> netdev11 but  forgot.

Well, once a hole is there, nothing we can do really, because of
compatibility with old kernels / old binaries.


But when a _new_ structure is defined, this is the time where we can ask
for doing sensible things ;)
