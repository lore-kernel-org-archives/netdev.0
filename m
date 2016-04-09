From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCHv2 net-next 1/6] sctp: add sctp_info dump api for sctp_diag
Date: Sat, 9 Apr 2016 11:19:44 -0400
Message-ID: <57091D90.4030905@mojatatu.com>
References: <cover.1460177331.git.lucien.xin@gmail.com>
 <c507274a984bd1b0a7e7a59d1e825352536efd25.1460177331.git.lucien.xin@gmail.com>
 <1460178984.6473.473.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:32815 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752257AbcDIPTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 11:19:46 -0400
Received: by mail-io0-f171.google.com with SMTP id o126so140988825iod.0
        for <netdev@vger.kernel.org>; Sat, 09 Apr 2016 08:19:46 -0700 (PDT)
In-Reply-To: <1460178984.6473.473.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-04-09 01:16 AM, Eric Dumazet wrote:

>
> Lots of holes in this structure...
>
>


I may have mentioned to you that there is 8 bit hole in tcp_info too ;->
(above tcpi_rto). Adding an 8 bit explicit pad seems useful
since it is already in the wild. I was going to send the patch after
netdev11 but  forgot.

cheers,
jamal
