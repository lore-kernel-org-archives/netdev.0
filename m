From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: What's the right way to use a *large* number of source addresses?
Date: Sat, 24 May 2014 08:06:41 -0400
Message-ID: <53808B51.4050308@mojatatu.com>
References: <6zlhtsvnqp.fsf@southpole.se>	 <CACP96tQMEQcTPZaCT7mehis-H5Sw_-74F6fSvZxB7Lr3Hqo0kQ@mail.gmail.com> <1400854458.5367.200.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?TmllbHMgTcO2bGxlcg==?= <nisse@southpole.se>,
	netdev <netdev@vger.kernel.org>, Jonas Bonn <jonas@southpole.se>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	sowmini varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:34820 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208AbaEXMGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 08:06:43 -0400
Received: by mail-ig0-f172.google.com with SMTP id uy17so1598753igb.17
        for <netdev@vger.kernel.org>; Sat, 24 May 2014 05:06:43 -0700 (PDT)
In-Reply-To: <1400854458.5367.200.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/14 10:14, Eric Dumazet wrote:

> Use the batch mode, and it will be much faster than ifconfig, as
> ifconfig does not support this mode (you need one fork()/exec() per IP
> address)
>
> ip -batch filename
>

The address dumping algorithm is a very likely contributor as well.
It tries to remember indices and then skips on the next iteration
all the way to where it left off.... has never been a big deal until
someone tries a substantial number of addresses.

cheers,
jamal
