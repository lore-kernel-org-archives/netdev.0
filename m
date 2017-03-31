From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 2/6] tools/lib/bpf: add support for
 BPF_PROG_TEST_RUN command
Date: Thu, 30 Mar 2017 20:26:18 -0700
Message-ID: <f2767209-2903-63d0-3a9a-1e0c9e011a7e@fb.com>
References: <20170331013157.3298003-1-ast@fb.com>
 <20170331013157.3298003-3-ast@fb.com>
 <af9a8353-3b6d-b50f-3348-9cf7cd167f81@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "Wangnan (F)" <wangnan0@huawei.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45219 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932873AbdCaD1B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 23:27:01 -0400
In-Reply-To: <af9a8353-3b6d-b50f-3348-9cf7cd167f81@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/30/17 8:15 PM, Wangnan (F) wrote:
>> -
>> +int bpf_program_test_run(int prog_fd, int repeat, void *data, __u32
>> size,
>> +             void *data_out, __u32 *size_out, __u32 *retval,
>> +             __u32 *duration);
>>
>
> Please call it bpf_prog_test_run() so it looks uniform with others.

sure. will do. good catch.
