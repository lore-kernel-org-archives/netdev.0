From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] Fix inaccurate helper function description
Date: Thu, 27 Apr 2017 20:55:42 -0700
Message-ID: <20170428035540.p34f5en63dfqsnam@ast-mbp>
References: <1493250083-1954-1-git-send-email-chenbofeng.kernel@gmail.com>
 <5901D1A3.9090207@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chenbo Feng <chenbofeng.kernel@gmail.com>, netdev@vger.kernel.org,
        mic@digikod.net, Chenbo Feng <fengc@google.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33657 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1423753AbdD1Dzq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 23:55:46 -0400
Received: by mail-pf0-f195.google.com with SMTP id 194so1745567pfv.0
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 20:55:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5901D1A3.9090207@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 01:10:27PM +0200, Daniel Borkmann wrote:
> On 04/27/2017 01:41 AM, Chenbo Feng wrote:
> > From: Chenbo Feng <fengc@google.com>
> > 
> > The description inside uapi/linux/bpf.h about bpf_get_socket_uid
> > helper function is no longer valid. It returns overflowuid rather
> > than 0 when failed.
> > 
> > Signed-off-by: Chenbo Feng <fengc@google.com>
> 
> "bpf: " prefix in patch subject line would have been good.

+1

last time missing 'bpf:' prefix caused me headaches during backporting,
so please always use it.
Also please use scripts/get_maintainer.pl to make sure
maintainers cc-ed on patches.
gmail delivers netdev list emails to my mailbox with 10+ hour delay
for some reason.

Acked-by: Alexei Starovoitov <ast@kernel.org>
