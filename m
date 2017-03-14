From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v3] net: ipv4: add support for ECMP hash policy
 choice
Date: Tue, 14 Mar 2017 16:27:15 -0700
Message-ID: <20170314162715.141f1d4b@xeon-e3>
References: <1489505775-2913-1-git-send-email-nikolay@cumulusnetworks.com>
        <20170314085502.47d48a4e@xeon-e3>
        <8088fe5f-0c0b-bdba-4fba-e9e28bbed02e@cumulusnetworks.com>
        <20170314.114837.619141079617104809.davem@davemloft.net>
        <20170314132506.6233b1e7@xeon-e3>
        <CAJieiUjeYH=u6W5p18JA=RwKuFpX6HSrifD0fRE1rR2e0fsvhw@mail.gmail.com>
        <20170314144204.20d5c3a5@xeon-e3>
        <CAJieiUgQpOidyE-OH73QQpMcQnzEgd+9bGPOKA-yAaFtb3fcwQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>, jkbs@redhat.com,
        Eric Dumazet <edumazet@google.com>,
        Peter Christensen <pch@ordbogen.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36052 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751107AbdCNX1X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 19:27:23 -0400
Received: by mail-pf0-f179.google.com with SMTP id o126so530647pfb.3
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 16:27:22 -0700 (PDT)
In-Reply-To: <CAJieiUgQpOidyE-OH73QQpMcQnzEgd+9bGPOKA-yAaFtb3fcwQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Mar 2017 15:38:40 -0700
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> >> >> > That's what my initial version did, but this was discussed during NetConf in Seville
> >> >> > and it was decided that it's best to make a global sysctl, thus the change.  
> >> >>
> >> >> Correct, we discussed this, and we all agreed to only have a sysctl for now.  
> >> >
> >> > Why? If you are going to have private discussions please post the rationale
> >> > in public.  
> >>
> >> Stephen, is there any reason to have a per ecmp route multipath algo
> >> selection ?.
> >> All platforms have a global multipath selection algo. I also don't see
> >> routing daemons ready or willing to specify a per ecmp route multipath
> >> selection algo attribute.  
> >
> > There is no compelling reason to make the attribute per route. But the
> > issue is more that configuration through sysctl's is problematic. It doesn't
> > fit into the standard API paradigm. Sysctl's are like routing patches not
> > part of the real CLI. Trying to trap sysctl's for things like switchedev
> > offload is particularly problematic. I can see the case for either way,
> > and don't have a fixed opinion.  
> 
> ok. understand the switchdev offload part. It was that way in the past...but
> today you can listen to sysctl updates on the netconf netlink channel.
> it works pretty well.

Is there another patch to add the NETCONFA_ECMP support?
