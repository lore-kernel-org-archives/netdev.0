From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2] net: bpf: reject invalid shifts
Date: Tue, 12 Jan 2016 20:07:44 -0800
Message-ID: <1452658064.1223.58.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452641302.1223.35.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160112234707.GA36167@ast-mbp.thefacebook.com>
	 <1452651098.1223.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160112.214315.2135966842775837844.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net, rabin@rab.in,
	netdev@vger.kernel.org, ast@kernel.org,
	linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33486 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752962AbcAMEHq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 23:07:46 -0500
Received: by mail-pa0-f51.google.com with SMTP id cy9so351041831pac.0
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 20:07:46 -0800 (PST)
In-Reply-To: <20160112.214315.2135966842775837844.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-01-12 at 21:43 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 12 Jan 2016 18:11:38 -0800
> 
> > As I said, it is possible some guys never noticed their BPF program
> > were 'broken' because this invalid shift was hidden in a dead code
> > part.
> 
> We should not hide bugs and unintended uses of operations with
> undefined behavior.

   JUMP 2:
   SHR  45
2: RET  10


was a valid program.

But a dumb loader decided to know better.
 
