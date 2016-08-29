From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v4 0/3] net: mpls: fragmentation and gso fixes
 for locally originated traffic
Date: Mon, 29 Aug 2016 08:12:28 -0600
Message-ID: <82084f2b-f8b4-eccd-d288-976afeed6a83@cumulusnetworks.com>
References: <1472094645-11452-1-git-send-email-dsa@cumulusnetworks.com>
 <20160826.114137.1990982027647137057.davem@davemloft.net>
 <20160829120729.GA25359@penelope.isobedori.kobe.vergenet.net>
 <20160829122949.GB25359@penelope.isobedori.kobe.vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, buytenh@wantstofly.org,
        ebiederm@xmission.com, rshearma@brocade.com, tom@herbertland.com,
        tgraf@suug.ch, olivier.dugeon@orange.com,
        alexander.duyck@gmail.com, roopa@cumulusnetworks.com
To: Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:37033 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756135AbcH2OMa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 10:12:30 -0400
Received: by mail-it0-f43.google.com with SMTP id d65so98541053ith.0
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 07:12:30 -0700 (PDT)
In-Reply-To: <20160829122949.GB25359@penelope.isobedori.kobe.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/29/16 6:29 AM, Simon Horman wrote: 
> I have tested this series for both of the following:
> * IPv4 in MPLS (just after the ethernet header)
> * IPv4 in MPLS in GRE (TEB)
> 
> Things seem to work fine.
> 
> Tested-by: Simon Horman <simon.horman@netronome.com>
> 
> Expanding a little on the above:
> 
> * I tested this using the test cases I have been working on for OvS here:
>   http://www.spinics.net/lists/netdev/msg391755.html
> 
>   Those test make use of namespaces connected using veth and
>   push/pop_mpls actions.

The 3rd patch in this set enables GSO for MPLS in veth meaning no software segmentation is done by default.

> 
> * As the above is quite new I also tested the patchset using my somewhat
>   more clumsy local test environment which uses KVM, virtio net and
>   push/pop_mpls actions.
> 

Awesome. Thanks for confirming.
