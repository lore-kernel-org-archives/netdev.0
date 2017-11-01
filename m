From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: Any hardware limitation for bpf testing?
Date: Wed, 01 Nov 2017 21:39:38 +0100
Message-ID: <59FA310A.5030105@iogearbox.net>
References: <CAPPenn_x6Cvh=8SU9nBPPVenMndB0YY4_b1cXwouxi7k6hSAag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sumit Semwal <sumit.semwal@linaro.org>
To: Orson Zhai <orson.zhai@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38005 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755025AbdKAUjl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 16:39:41 -0400
In-Reply-To: <CAPPenn_x6Cvh=8SU9nBPPVenMndB0YY4_b1cXwouxi7k6hSAag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/2017 12:16 PM, Orson Zhai wrote:
[...]
> We have ran some bpf test within kselftest for 4.14.0-rc5-next-20171018 at
> some hardware resource limited devices. Say Hikey Board (arm64 core) with
> 2GB memory.
>
> The test processes was killed by OOM which made the test failed.
>
> We investigate the reason and find bpf test will require a large mount of
> memory to run.
>
> Like some code in selftests/bpf/test_maps.c
>
>> static void test_hashmap_walk(int task, void *data)
>> {
>>       int fd, i, max_entries = 100000;
>                                           ^^^^^^^^^^^^
>>        ......
>>       }
>
> The test will pass smoothly when we set max_entries to a smaller number.

Feel free to send a patch to set this to something lower, maybe 10k
or such, if that will work for your setup.

Thanks,
Daniel
