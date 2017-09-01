From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/3] bpf: Add lru_hash_lookup performance test
Date: Fri, 01 Sep 2017 11:12:39 +0200
Message-ID: <59A92487.2060609@iogearbox.net>
References: <20170901062713.1842249-1-kafai@fb.com> <20170901062713.1842249-2-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>, kernel-team@fb.com
To: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38251 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751595AbdIAJMl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 05:12:41 -0400
In-Reply-To: <20170901062713.1842249-2-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2017 08:27 AM, Martin KaFai Lau wrote:
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

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
