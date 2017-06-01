From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/8] Introduce bpf ID
Date: Thu, 01 Jun 2017 14:56:24 -0400 (EDT)
Message-ID: <20170601.145624.1727289342819240334.davem@davemloft.net>
References: <18d3c571-7434-eaea-43dc-d237712309d1@gmail.com>
        <cae83d5f-85ea-4c16-5f6b-2b71f0768b05@fb.com>
        <5e8b1713-0220-5c53-210d-8040efd36cfb@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, kubakici@wp.pl, kafai@fb.com,
        hannes@stressinduktion.org, netdev@vger.kernel.org,
        daniel@iogearbox.net, kernel-team@fb.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58546 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751097AbdFAS40 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 14:56:26 -0400
In-Reply-To: <5e8b1713-0220-5c53-210d-8040efd36cfb@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Thu, 1 Jun 2017 12:52:28 -0600

> On 6/1/17 12:27 PM, Alexei Starovoitov wrote:
>> 'I want to retrieve original instructions' is not a problem. It's a
>> push for 'solution'. Explaining 'why' you want to see original
>> instructions would describe the actual problem.
> 
> I have explained this.
> 
> You are creating this hyper-complex almost completely invisible
> infrastructure. You are enabling binary blobs that can bypass the
> network stack and modify packets with almost no introspection on what is
> happening. BPF code can from a variety of sources -- OS vendors,
> upstream repos, 3rd party vendors (eg., H/W vendors), and "in-house"
> development. Each will swear to the end that any observed problem is not
> with their code. In my experience, it falls on to the OS and kernel
> experts to figure out why Linux is breaking something. To do that we
> need tools to look at what code is running where and something that can
> be used in production environments not requiring a disruption to the
> service that the box is providing.

I'm not convinced that the verifier processed instruction stream
cannot provide that facility properly.

In fact, because of how the maps and tail calls work, you can only
figure out what is really executing by looking at the final processed
instruction stream.
