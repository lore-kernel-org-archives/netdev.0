From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: dev_map_alloc() shouldn't return NULL
Date: Sat, 22 Jul 2017 12:09:53 +0200
Message-ID: <59732471.5080504@iogearbox.net>
References: <20170722074004.3abeucov67n3sbqs@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>,
        Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53168 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752199AbdGVKJ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2017 06:09:59 -0400
In-Reply-To: <20170722074004.3abeucov67n3sbqs@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2017 09:40 AM, Dan Carpenter wrote:
> We forgot to set the error code on two error paths which means that we
> return ERR_PTR(0) which is NULL.  The caller, find_and_alloc_map(), is
> not expecting that and will have a NULL dereference.
>
> Fixes: 546ac1ffb70d ("bpf: add devmap, a map for storing net device references")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
