From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v7 0/6] Add eBPF hooks for cgroups
Date: Fri, 28 Oct 2016 09:00:51 -0600
Message-ID: <28133272-ff53-8a02-cc5d-844b22819e39@cumulusnetworks.com>
References: <1477390454-12553-1-git-send-email-daniel@zonque.org>
 <20161026195933.GA2031@salvia>
 <20161027033502.GA43960@ast-mbp.thefacebook.com>
 <20161028112839.GA29798@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Daniel Mack <daniel@zonque.org>, htejun@fb.com,
        daniel@iogearbox.net, ast@fb.com, davem@davemloft.net,
        kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org, sargun@sargun.me, cgroups@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:36849 "EHLO
        mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754677AbcJ1PAx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 11:00:53 -0400
Received: by mail-yw0-f171.google.com with SMTP id u124so89121667ywg.3
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 08:00:53 -0700 (PDT)
In-Reply-To: <20161028112839.GA29798@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/28/16 5:28 AM, Pablo Neira Ayuso wrote:
> I saw those, I would really like to have a closer look at David
> Ahern's usecase since that skb iif mangling looks kludgy to me, and
> given this is exposing a new helper for general use, not only vrf, it
> would be good to make sure helpers provide something useful for
> everyone. So that new helper is questionable at this stage IMO. I'm
> concerned that people may start using bpf as the adhesive tape to glue
> things to solve probably design problems.

It's changing sk_bound_dev_if on a socket when the socket is created, not skb iif. I explain the need in the cover letter. I have also explained the use case in the other attempts to solve this problem -- a stand alone l3mdev cgroup and adding a default setting to the task struct.
