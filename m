From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 0/2] tools: add bpftool
Date: Wed, 27 Sep 2017 01:44:56 +0100
Message-ID: <20170927014456.7f4198f7@cakuba>
References: <20170926153522.31500-1-jakub.kicinski@netronome.com>
        <5522855a-937f-b2cb-4c74-3448d1680b10@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, davem@davemloft.net,
        hannes@stressinduktion.org, oss-drivers@netronome.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:38747 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1030622AbdI0ApB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 20:45:01 -0400
In-Reply-To: <5522855a-937f-b2cb-4c74-3448d1680b10@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Sep 2017 17:32:31 -0600, David Ahern wrote:
> On 9/26/17 9:35 AM, Jakub Kicinski wrote:
> > I'm looking for a home for bpftool, Daniel suggested that 
> > tools/net could be a good place, since there are only BPF
> > utilities there already.
> > 
> > The tool should be complete for simple use cases and we
> > will continue extending it as we go along.  E.g. providing
> > disassembly of loaded programs directly using LLVM library
> > and JSON output are high on the priority list.  
> 
> I have found this to be a very useful tool. Thanks for working on it.
> Moving it into the kernel will make it easier to build since it relies
> on libbpf and other files from the kernel tree.
> 
> One change I have made locally is to link against libbpf.a. That way I
> only need to copy one file to a system to use it.

Thanks!  I made the same change here, this patchset will have bpftool
linked against libbpf statically.
