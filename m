From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] selftests/net: Fixes psock_fanout CBPF test case
Date: Thu, 20 Apr 2017 15:39:53 -0400 (EDT)
Message-ID: <20170420.153953.2254487909608010855.davem@davemloft.net>
References: <20170418151416.17858-1-maloneykernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com,
        maloney@google.com
To: maloneykernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48230 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947122AbdDTTjz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 15:39:55 -0400
In-Reply-To: <20170418151416.17858-1-maloneykernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Maloney <maloneykernel@gmail.com>
Date: Tue, 18 Apr 2017 11:14:16 -0400

> From: Mike Maloney <maloney@google.com>
> 
> 'psock_fanout' has been failing since commit 4d7b9dc1f36a9 ("tools:
> psock_lib: harden socket filter used by psock tests").  That commit
> changed the CBPF filter to examine the full ethernet frame, and was
> tested on 'psock_tpacket' which uses SOCK_RAW.  But 'psock_fanout' was
> also using this same CBPF in two places, for filtering and fanout, on a
> SOCK_DGRAM socket.
> 
> Change 'psock_fanout' to use SOCK_RAW so that the CBPF program used with
> SO_ATTACH_FILTER can examine the entire frame.  Create a new CBPF
> program for use with PACKET_FANOUT_DATA which ignores the header, as it
> cannot see the ethernet header.
> 
> Tested: Ran tools/testing/selftests/net/psock_{fanout,tpacket} 10 times,
> and they all passed.
> 
> Fixes: 4d7b9dc1f36a9 ("tools: psock_lib: harden socket filter used by psock tests")
> Signed-off-by: 'Mike Maloney <maloneykernel@gmail.com>'

Applied, thanks.
