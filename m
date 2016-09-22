From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Thu, 22 Sep 2016 17:30:10 -0400
Message-ID: <20160922213010.GA32052@oracle.com>
References: <20160920163108.GP8920@oracle.com>
 <20160920184333.17444823@griffin>
 <20160920190929.57ddaeb0@griffin>
 <20160922.015242.735026657310158125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jbenc@redhat.com, netdev@vger.kernel.org,
        hannes@stressinduktion.org, aduyck@mirantis.com,
        daniel@iogearbox.net, pabeni@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20065 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933339AbcIVVaj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 17:30:39 -0400
Content-Disposition: inline
In-Reply-To: <20160922.015242.735026657310158125.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/22/16 01:52), David Miller wrote:
> Alternatively we can do Alexander Duyck's trick, by pushing
> the headers into the frag list, forcing a pull and realignment
> by the next protocol layer.

What is the "Alexander Duyck trick" (hints about module or commit id,
where this can be found, please)?

Is this basically about, e.g., putting the vxlanhdr in its own
skb_frag_t, or something else?

--Sowmini
