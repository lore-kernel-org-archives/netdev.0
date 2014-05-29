From: David Ahern <dsahern@gmail.com>
Subject: Re: Scaling 'ip addr add' (was Re: What's the right way to use a
 *large* number of source addresses?)
Date: Thu, 29 May 2014 10:19:40 -0600
Message-ID: <53875E1C.2040708@gmail.com>
References: <CACP96tRSpop=Sf58qE6TXeF+a-5nqfCj5d12bwD9WaYue_6_UA@mail.gmail.com>	<alpine.LFD.2.11.1405290853530.1636@ja.home.ssi.bg> <CACP96tR8v=sujsGqFPefTw09X3WEud6-3KTX5j48ijX=hyyerw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?B?TmllbHMgTcO2bGxlcg==?= <nisse@southpole.se>,
	netdev <netdev@vger.kernel.org>, Jonas Bonn <jonas@southpole.se>
To: sowmini varadhan <sowmini05@gmail.com>,
	Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:60927 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757778AbaE2QTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 12:19:43 -0400
Received: by mail-pa0-f49.google.com with SMTP id kp14so610915pab.22
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 09:19:43 -0700 (PDT)
In-Reply-To: <CACP96tR8v=sujsGqFPefTw09X3WEud6-3KTX5j48ijX=hyyerw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/29/14, 10:11 AM, sowmini varadhan wrote:
> I'm still not sure I understand*why*  check_lifetime ends
> up being expensive, though. For this particular test, all the
...
>
> fib_sync_up() could also use a magnifying glass - was going to
> look at this later.

Annotation feature of perf should help
     perf record -ga -- <command>

     'perf report' with a TUI and then hit 'a' for annotation mode
     or use 'perf annotate -k vmlinux -s <symbol name>'

David
