From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tools: psock_lib: harden socket filter used
 by psock tests
Date: Thu, 12 Jan 2017 10:51:18 -0500 (EST)
Message-ID: <20170112.105118.871474657291324075.davem@davemloft.net>
References: <cover.1484060892.git.sowmini.varadhan@oracle.com>
        <2dbc0b384193b76bcb7f1845e1f81768610cc2b5.1484060892.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, willemb@google.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51070 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750734AbdALPvU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 10:51:20 -0500
In-Reply-To: <2dbc0b384193b76bcb7f1845e1f81768610cc2b5.1484060892.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Thu, 12 Jan 2017 05:10:11 -0800

> The filter added by sock_setfilter is intended to only permit
> packets matching the pattern set up by create_payload(), but
> we only check the ip_len, and a single test-character in
> the IP packet to ensure this condition.
> 
> Harden the filter by adding additional constraints so that we only
> permit UDP/IPv4 packets that meet the ip_len and test-character
> requirements. Include the bpf_asm src as a comment, in case this
> needs to be enhanced in the future
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

Applied, thanks.
