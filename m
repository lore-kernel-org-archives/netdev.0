From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v2 1/3] bpf: Use 1<<16 as ceiling for immediate alignment
 in verifier.
Date: Thu, 18 May 2017 19:41:24 +0100
Message-ID: <3ad43836-b18c-4d60-d968-bae2e21f2548@solarflare.com>
References: <20170515.120431.1588221938554447723.davem@davemloft.net>
 <754f2c39-fdb0-2407-c2f2-aa36d506d202@solarflare.com>
 <f2bff26d-8b4d-c6a2-23c9-9db198569e40@fb.com>
 <50288778-10f6-7201-c979-bfe4635831fc@solarflare.com>
 <e873f261-e1c1-c344-3d72-254623e0c91a@solarflare.com>
 <97910214-213c-c5c6-4a02-adc16cd836aa@fb.com>
 <c8e4ce49-5707-3d6d-c8c2-80dd8335d981@solarflare.com>
 <739ef342-728c-de57-c2a2-03fa85b3a246@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <alexei.starovoitov@gmail.com>, <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@fb.com>,
        David Miller <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:55894 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753965AbdERSli (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 14:41:38 -0400
In-Reply-To: <739ef342-728c-de57-c2a2-03fa85b3a246@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implementations (still in Python for now) at
https://gist.github.com/ecree-solarflare/0665d5b46c2d8d08de2377fbd527de8d
(I left out division, because it's so weak.)

I still can't prove + and - are correct, but they've passed every test
 case I've come up with so far.  * seems pretty obviously correct as long
 as the + it uses is.  Bitwise ops and shifts are trivial to prove.

-Ed
