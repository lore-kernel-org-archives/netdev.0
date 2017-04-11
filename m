From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: add test_progs to .gitignore
Date: Tue, 11 Apr 2017 13:49:10 +0200
Message-ID: <58ECC2B6.1020104@iogearbox.net>
References: <20170411113538.31423-1-alexander@alemayhu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com
To: Alexander Alemayhu <alexander@alemayhu.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41888 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751248AbdDKLtM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 07:49:12 -0400
In-Reply-To: <20170411113538.31423-1-alexander@alemayhu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2017 01:35 PM, Alexander Alemayhu wrote:
> Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>
> ---
>   tools/testing/selftests/bpf/.gitignore | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/tools/testing/selftests/bpf/.gitignore b/tools/testing/selftests/bpf/.gitignore
> index 541d9d7fad5a..2fe8766e204f 100644
> --- a/tools/testing/selftests/bpf/.gitignore
> +++ b/tools/testing/selftests/bpf/.gitignore
> @@ -3,3 +3,4 @@ test_maps
>   test_lru_map
>   test_lpm_map
>   test_tag
> +test_progs

Good point, we should also add '*.o' in that case for the
TEST_GEN_FILES specified objs that clang generates.
