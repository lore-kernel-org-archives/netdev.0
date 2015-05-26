From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] x86: bpf_jit: fix compilation of large bpf programs
Date: Tue, 26 May 2015 08:29:58 -0700
Message-ID: <1432654198.4060.248.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432334575-16959-1-git-send-email-ast@plumgrid.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB3EA6A@AcuExch.aculab.com>
	 <1432650922.4060.236.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB3ECB8@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Alexei Starovoitov' <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:33472 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753798AbbEZPaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 11:30:01 -0400
Received: by igbpi8 with SMTP id pi8so62486777igb.0
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 08:30:00 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB3ECB8@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-26 at 15:13 +0000, David Laight wrote:

> Yes, interesting, a benchmark that manages to run a lot of code 'cold cache'.

We have binaries here at Google with 400 or 500 MBytes of text.

Not benchmark, super real workloads you know.
