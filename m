From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: fix oops on allocation failure
Date: Fri, 25 Aug 2017 22:47:09 +0200
Message-ID: <59A08CCD.2050603@iogearbox.net>
References: <20170825202714.64ivixeindjph3z6@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>,
        Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34862 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754728AbdHYUrV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 16:47:21 -0400
In-Reply-To: <20170825202714.64ivixeindjph3z6@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2017 10:27 PM, Dan Carpenter wrote:
> "err" is set to zero if bpf_map_area_alloc() fails so it means we return
> ERR_PTR(0) which is NULL.  The caller, find_and_alloc_map(), is not
> expecting NULL returns and will oops.
>
> Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
