From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 1/3] bpf: Add lru_hash_lookup performance test
Date: Fri, 1 Sep 2017 07:22:32 -0700
Message-ID: <21166cda-609b-8843-d223-83ce72e62a10@fb.com>
References: <20170901062713.1842249-1-kafai@fb.com>
 <20170901062713.1842249-2-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:54288 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751964AbdIAOXJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 10:23:09 -0400
In-Reply-To: <20170901062713.1842249-2-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/31/17 11:27 PM, Martin KaFai Lau wrote:
> Create a new case to test the LRU lookup performance.
>
> At the beginning, the LRU map is fully loaded (i.e. the number of keys
> is equal to map->max_entries).   The lookup is done through key 0
> to num_map_entries and then repeats from 0 again.
>
> This patch also creates an anonymous struct to properly
> name the test params in stress_lru_hmap_alloc() in map_perf_test_kern.c.
>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
