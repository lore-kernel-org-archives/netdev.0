From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 2/2] bpf: inline map in map lookup functions for
 array and htab
Date: Fri, 18 Aug 2017 17:05:10 -0700
Message-ID: <f5309f0a-b647-c759-e0c0-efdf5a1d8002@fb.com>
References: <cover.1503100047.git.daniel@iogearbox.net>
 <501683f73390c81a7abaa0683f3675860a79adc7.1503100047.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:45647 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751060AbdHSAFh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 20:05:37 -0400
In-Reply-To: <501683f73390c81a7abaa0683f3675860a79adc7.1503100047.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/18/17 4:51 PM, Daniel Borkmann wrote:
> Avoid two successive functions calls for the map in map lookup, first
> is the bpf_map_lookup_elem() helper call, and second the callback via
> map->ops->map_lookup_elem() to get to the map in map implementation.
> Implementation inlines array and htab flavor for map in map lookups.
>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

lgtm
thanks for adding this optimization.
Acked-by: Alexei Starovoitov <ast@kernel.org>
