From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Tue, 20 Sep 2016 13:24:16 -0400
Message-ID: <20160920172416.GS8920@oracle.com>
References: <20160920142700.GJ8920@oracle.com>
 <20160920181114.0ac7cfa0@griffin>
 <20160920163108.GP8920@oracle.com>
 <20160920184333.17444823@griffin>
 <20160920190929.57ddaeb0@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        hannes@stressinduktion.org, aduyck@mirantis.com,
        daniel@iogearbox.net, pabeni@redhat.com
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:26655 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751643AbcITRYh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 13:24:37 -0400
Content-Disposition: inline
In-Reply-To: <20160920190929.57ddaeb0@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/20/16 19:09), Jiri Benc wrote:
> 
> But the point stands, we have much greater problems here than VXLAN.
> And I don't think that wrapping all IP address accesses into
> get/put_unaligned all around the stack is the solution.
> 

Agreed, and I think Tom made that point too. 
For the immediate pain, Hannes' suggestion of making vxlanhdr
__packed takes care of the noise from vxlan_build_skb, so I will
spin out a v2 that takes care of this one, at least.

--Sowmini
