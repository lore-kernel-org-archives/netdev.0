From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next] bpf: netdev is never null in __dev_map_flush
Date: Wed, 23 Aug 2017 18:25:38 -0700
Message-ID: <1efe2357-43aa-8976-75a0-62d4572287cc@fb.com>
References: <d8e0306b70b05bdd5e628459863d1027c8c26959.1503537400.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <john.fastabend@gmail.com>, <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:44390 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751092AbdHXB0Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 21:26:24 -0400
In-Reply-To: <d8e0306b70b05bdd5e628459863d1027c8c26959.1503537400.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/23/17 6:20 PM, Daniel Borkmann wrote:
> No need to test for it in fast-path, every dev in bpf_dtab_netdev
> is guaranteed to be non-NULL, otherwise dev_map_update_elem() will
> fail in the first place.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

wow. interesting. I'm surprised you see a difference from
such micro-optimization.
Acked-by: Alexei Starovoitov <ast@kernel.org>
