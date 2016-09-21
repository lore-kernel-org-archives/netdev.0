From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V2] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Wed, 21 Sep 2016 09:53:31 -0700
Message-ID: <1474476811.23058.78.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160920185737.GU8920@oracle.com>
         <4617aca3-8d44-e99a-cc5a-1088b30ae327@stressinduktion.org>
         <20160921161457.GA17116@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        netdev@vger.kernel.org, jbenc@redhat.com, davem@davemloft.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33148 "EHLO
        mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756978AbcIUQyW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 12:54:22 -0400
Received: by mail-pa0-f46.google.com with SMTP id hm5so20146602pac.0
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 09:53:33 -0700 (PDT)
In-Reply-To: <20160921161457.GA17116@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-09-21 at 09:14 -0700, Alexei Starovoitov wrote:

> 
> I think it's the opposite. Even on x86 compiler will use byte loads.

Unless you tweaked gcc, it should still use word loads on x86.
