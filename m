From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] net/vxlan: Avoid unaligned access in
 vxlan_build_skb()
Date: Tue, 20 Sep 2016 19:15:59 +0200
Message-ID: <20160920191559.09c85ca7@griffin>
References: <20160920142700.GJ8920@oracle.com>
        <20160920181114.0ac7cfa0@griffin>
        <20160920163108.GP8920@oracle.com>
        <20160920184333.17444823@griffin>
        <20160920170742.GR8920@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        hannes@stressinduktion.org, aduyck@mirantis.com,
        daniel@iogearbox.net, pabeni@redhat.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38846 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754132AbcITRQE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 13:16:04 -0400
In-Reply-To: <20160920170742.GR8920@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Sep 2016 13:07:42 -0400, Sowmini Varadhan wrote:
> I will try out Hannes' solution (which makes sense) in a moment, 
> and report back.

No objections to marking the struct as packed. Will only push the
problem to a different place, though.

 Jiri
