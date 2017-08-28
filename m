From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] bpf: fix oops on allocation failure
Date: Mon, 28 Aug 2017 08:58:31 -0700
Message-ID: <59A43DA7.4070101@gmail.com>
References: <20170825202714.64ivixeindjph3z6@mwanda> <59A08CCD.2050603@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
        Dan Carpenter <dan.carpenter@oracle.com>,
        Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36914 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751283AbdH1P6n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 11:58:43 -0400
In-Reply-To: <59A08CCD.2050603@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2017 01:47 PM, Daniel Borkmann wrote:
> On 08/25/2017 10:27 PM, Dan Carpenter wrote:
>> "err" is set to zero if bpf_map_area_alloc() fails so it means we return
>> ERR_PTR(0) which is NULL.  The caller, find_and_alloc_map(), is not
>> expecting NULL returns and will oops.
>>
>> Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Thanks.

Acked-by: John Fastabend <john.fastabend@gmail.com>
