From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] tools: psock_lib: harden socket filter used
 by psock tests
Date: Thu, 12 Jan 2017 15:37:20 +0100
Message-ID: <587794A0.8030807@iogearbox.net>
References: <cover.1484060892.git.sowmini.varadhan@oracle.com> <2dbc0b384193b76bcb7f1845e1f81768610cc2b5.1484060892.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, davem@davemloft.net
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41220 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750720AbdALOhX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 09:37:23 -0500
In-Reply-To: <2dbc0b384193b76bcb7f1845e1f81768610cc2b5.1484060892.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2017 02:10 PM, Sowmini Varadhan wrote:
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

LGTM, thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
