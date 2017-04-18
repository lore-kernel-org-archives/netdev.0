From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net] selftests/net: Fixes psock_fanout CBPF test case
Date: Tue, 18 Apr 2017 11:26:16 -0400
Message-ID: <20170418152616.GE18699@oracle.com>
References: <20170418151416.17858-1-maloneykernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        Mike Maloney <maloney@google.com>
To: Mike Maloney <maloneykernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43456 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751739AbdDRP00 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 11:26:26 -0400
Content-Disposition: inline
In-Reply-To: <20170418151416.17858-1-maloneykernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (04/18/17 11:14), Mike Maloney wrote:
> Change 'psock_fanout' to use SOCK_RAW so that the CBPF program used with
> SO_ATTACH_FILTER can examine the entire frame.  Create a new CBPF
> program for use with PACKET_FANOUT_DATA which ignores the header, as it
> cannot see the ethernet header.

Fix look good to me, but could you please also add the bpf_asm input
as a comment to the C code, in case we want to to read/extend  this
down the road?

--Sowmini
