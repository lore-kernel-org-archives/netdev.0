From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next] samples/bpf: Add support for SKB_MODE to xdp1
 and xdp_tx_iptunnel
Date: Thu, 27 Apr 2017 09:38:37 -0700
Message-ID: <085b8b0f-7751-0be4-d3b7-3c06f2cc602b@fb.com>
References: <1493309473-27384-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>
To: David Ahern <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:43994 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932573AbdD0QjS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 12:39:18 -0400
In-Reply-To: <1493309473-27384-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/27/17 9:11 AM, David Ahern wrote:
> Add option to xdp1 and xdp_tx_iptunnel to insert xdp program in
> SKB_MODE:
>  - update set_link_xdp_fd to take a flags argument that is added to the
>    RTM_SETLINK message
>
>  - Add -S option to xdp1 and xdp_tx_iptunnel user code. When passed in
>    XDP_FLAGS_SKB_MODE is set in the flags arg passed to set_link_xdp_fd
>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

awesome. thanks!
Acked-by: Alexei Starovoitov <ast@kernel.org>
