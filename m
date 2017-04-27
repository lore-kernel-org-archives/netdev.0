From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] samples/bpf: Add support for SKB_MODE to xdp1
 and xdp_tx_iptunnel
Date: Thu, 27 Apr 2017 12:49:44 -0400 (EDT)
Message-ID: <20170427.124944.862121075657884005.davem@davemloft.net>
References: <1493309473-27384-1-git-send-email-dsa@cumulusnetworks.com>
        <085b8b0f-7751-0be4-d3b7-3c06f2cc602b@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org,
        daniel@iogearbox.net
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42964 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968076AbdD0Qtq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 12:49:46 -0400
In-Reply-To: <085b8b0f-7751-0be4-d3b7-3c06f2cc602b@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Thu, 27 Apr 2017 09:38:37 -0700

> On 4/27/17 9:11 AM, David Ahern wrote:
>> Add option to xdp1 and xdp_tx_iptunnel to insert xdp program in
>> SKB_MODE:
>>  - update set_link_xdp_fd to take a flags argument that is added to the
>>    RTM_SETLINK message
>>
>>  - Add -S option to xdp1 and xdp_tx_iptunnel user code. When passed in
>>    XDP_FLAGS_SKB_MODE is set in the flags arg passed to set_link_xdp_fd
>>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> 
> awesome. thanks!
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Indeed, very awesome.

Applied!
