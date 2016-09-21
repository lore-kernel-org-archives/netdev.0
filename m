From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next V2] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Wed, 21 Sep 2016 10:12:24 -0700
Message-ID: <20160921171222.GA18327@ast-mbp.thefacebook.com>
References: <20160920185737.GU8920@oracle.com>
 <4617aca3-8d44-e99a-cc5a-1088b30ae327@stressinduktion.org>
 <20160921161457.GA17116@ast-mbp.thefacebook.com>
 <1474476811.23058.78.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        netdev@vger.kernel.org, jbenc@redhat.com, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34374 "EHLO
        mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752320AbcIURM3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 13:12:29 -0400
Received: by mail-pa0-f50.google.com with SMTP id wk8so20242451pab.1
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 10:12:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1474476811.23058.78.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 21, 2016 at 09:53:31AM -0700, Eric Dumazet wrote:
> On Wed, 2016-09-21 at 09:14 -0700, Alexei Starovoitov wrote:
> 
> > 
> > I think it's the opposite. Even on x86 compiler will use byte loads.
> 
> Unless you tweaked gcc, it should still use word loads on x86.

> checked that on x86-64 actually. Also clearly visible here:

ahh. ok. good to know. thanks guys!
