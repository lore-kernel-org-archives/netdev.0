From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/sunrpc/: some cleanups
Date: Mon, 27 Dec 2004 18:57:21 -0800
Message-ID: <20041227185721.6adb9867.davem@davemloft.net>
References: <20041212211907.GZ22324@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20041212211907.GZ22324@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 12 Dec 2004 22:19:07 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> The patch below contains the following cleanups:
> - make some needlessly global code static
> - remove the following unused global functions:
>   - net/sunrpc/auth_gss/gss_generic_token.c: g_get_mech_oid
>   - net/sunrpc/cache.c: cache_find
>   - net/sunrpc/cache.c: cache_drop
>   - net/sunrpc/xdr.c: xdr_decode_netobj_fixed
>   - net/sunrpc/xdr.c: xdr_shift_iovec
>   - net/sunrpc/xdr.c: xdr_kmap
>   - net/sunrpc/xdr.c: xdr_kunmap
> - remove the following unused global structs:
>   - net/sunrpc/auth_gss/gss_krb5_mech.c: gss_mech_krb5_oid
>   - net/sunrpc/auth_gss/gss_spkm3_mech.c: gss_mech_spkm3_oid
>   - net/sunrpc/rpc_pipe.c: rpc_pipe_iops
> - remove the EXPORT_SYMBOL(cache_clean)
> 
> Please review this patch.

Looks fine.  Applied, thanks Adrian.
