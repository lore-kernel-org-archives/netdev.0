From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC PATCH net-next 0/5] tcp: TCP tracer
Date: Wed, 17 Dec 2014 13:56:33 -0700
Message-ID: <5491EE01.5020406@gmail.com>
References: <CAADnVQ+zkNL9sJhJuAiQ_y4bis=Sck5pzG86qccXE9vvM0-drQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Martin KaFai Lau <kafai@fb.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Lawrence Brakmo <brakmo@fb.com>, Josef Bacik <jbacik@fb.com>,
	Kernel Team <Kernel-team@fb.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:51204 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751335AbaLQU4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 15:56:37 -0500
Received: by mail-pd0-f178.google.com with SMTP id r10so16990502pdi.9
        for <netdev@vger.kernel.org>; Wed, 17 Dec 2014 12:56:36 -0800 (PST)
In-Reply-To: <CAADnVQ+zkNL9sJhJuAiQ_y4bis=Sck5pzG86qccXE9vvM0-drQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/14 1:42 PM, Alexei Starovoitov wrote:
>> It is not strictly necessary to carry vmlinux, that is just a probe
>> >point resolution time problem, solvable when generating a shell script,
>> >on the development machine, to insert the probes.
> on N development machines with kernels that
> would match worker machines...
> I'm not saying it's impossible, just operationally difficult.
> This is my understanding of Martin's use case.
>

That's the use case I am talking about ... N-different kernel versions 
and the probe definitions would need to be generated at *build* time of 
the kernel that uses a cross-compile environment. ie., can't assume 
there is a development machine running the kernel from which you can 
generate the probe definitions. This gets messy quick for embedded 
deployments.

David
