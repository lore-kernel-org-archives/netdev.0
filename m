From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [iproute PATCH v2 08/18] ss: Turn generic_proc_open() wrappers
 into macros
Date: Mon, 5 Dec 2016 17:02:20 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0235052@AcuExch.aculab.com>
References: <20161202104002.17310-1-phil@nwl.cc>
 <20161202104002.17310-9-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Phil Sutter' <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.194]:56782 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751492AbcLERC3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 12:02:29 -0500
In-Reply-To: <20161202104002.17310-9-phil@nwl.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter
> Sent: 02 December 2016 10:40
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  misc/ss.c | 89 ++++++++++++++-------------------------------------------------
>  1 file changed, 19 insertions(+), 70 deletions(-)
> 
> diff --git a/misc/ss.c b/misc/ss.c
> index ad38eb97b0055..71040a82ca6b1 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -327,76 +327,25 @@ static FILE *generic_proc_open(const char *env, const char *name)
> 
>  	return fopen(p, "r");
>  }
> -
> -static FILE *net_tcp_open(void)
> -{
> -	return generic_proc_open("PROC_NET_TCP", "net/tcp");
> -}
...
> +#define net_tcp_open()		generic_proc_open("PROC_NET_TCP", "net/tcp")
...

Does that make any difference at all?
The compiler should inline the static functions.

	David
