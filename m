From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 0/5] bridge: per vlan dst_metadata support
Date: Thu, 02 Feb 2017 22:06:35 -0800
Message-ID: <58941DEB.8030507@cumulusnetworks.com>
References: <1485932395-58422-1-git-send-email-roopa@cumulusnetworks.com> <20170202.205053.1531692095462887882.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
        nikolay@cumulusnetworks.com, tgraf@suug.ch,
        hannes@stressinduktion.org, jbenc@redhat.com, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33791 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752525AbdBCGHY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 01:07:24 -0500
Received: by mail-pf0-f173.google.com with SMTP id y143so3456683pfb.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 22:06:38 -0800 (PST)
In-Reply-To: <20170202.205053.1531692095462887882.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/2/17, 5:50 PM, David Miller wrote:
> I see a lot of "complexity of bridging layer" pushback on these
> changes, and I understand where that is coming from.
>
> But really this isn't even, at a high level, really a bridging change.
>
> What it's doing is making lwtunnel objects more useful.
>
> Now that we have lightweight tunnels and netdevs, we will constantly
> have this struggle trying to figure out how to make lwtunnel objects
> apply to the same cases that netdevs currently only work for.
>
> Because once you run into one of these situations where only netdevs
> work, you are screwed and lwtunnels and their scalability benefit
> might as well not even exist.
>
> To be completely honest, in this case it's pretty clear:
>
> 1) It makes vxlan lwtunnel objects more usable for bridges.
>
> 2) It does not make lwtunnels more bloated or consume more memory
>    or cpu in the dataplane fast paths.
>
> 3) It makes uptake of lwtunnels higher, because they can be used
>    in more places.
>
> So I think this change is a win and a move forward.

Thanks David
