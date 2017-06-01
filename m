From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH v2 net-next 0/8] Introduce bpf ID
Date: Thu, 1 Jun 2017 12:00:38 -0700
Message-ID: <20170601120038.680c8169@cakuba.lan>
References: <cover.1496256722.git.kafai@fb.com>
        <20170531192256.0e0d0ce1@cakuba.lan>
        <3f269312-efd4-86fc-e8e2-814af5898648@gmail.com>
        <6ab73989-6246-ba15-7178-7863a110165c@fb.com>
        <18d3c571-7434-eaea-43dc-d237712309d1@gmail.com>
        <cae83d5f-85ea-4c16-5f6b-2b71f0768b05@fb.com>
        <5e8b1713-0220-5c53-210d-8040efd36cfb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>, Martin KaFai Lau <kafai@fb.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
        kernel-team@fb.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:54121 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751083AbdFATAp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 15:00:45 -0400
In-Reply-To: <5e8b1713-0220-5c53-210d-8040efd36cfb@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Jun 2017 12:52:28 -0600, David Ahern wrote:
> On 6/1/17 12:27 PM, Alexei Starovoitov wrote:
> > 'I want to retrieve original instructions' is not a problem. It's a
> > push for 'solution'. Explaining 'why' you want to see original
> > instructions would describe the actual problem.  
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

Forgive my ignorance, but is it possible to dump code of a loaded
module out of the kernel?
