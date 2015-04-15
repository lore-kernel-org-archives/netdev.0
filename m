From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: ip_tunnel: Remove gratuitous skb scrubbing
Date: Wed, 15 Apr 2015 17:41:26 +0200
Message-ID: <552E86A6.9000101@6wind.com>
References: <20150415100107.GA3655@gondor.apana.org.au> <552E3B7A.2040701@6wind.com> <20150415102229.GA3917@gondor.apana.org.au> <20150415135739.GA5534@gondor.apana.org.au>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	James Morris <jmorris@redhat.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:33902 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755702AbbDOPl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 11:41:29 -0400
Received: by wgso17 with SMTP id o17so51516951wgs.1
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 08:41:28 -0700 (PDT)
In-Reply-To: <20150415135739.GA5534@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/04/2015 15:57, Herbert Xu a =E9crit :
> On Wed, Apr 15, 2015 at 06:22:29PM +0800, Herbert Xu wrote:
[snip]
> Subject: skbuff: Do not scrub skb mark within the same name space
>
> The commit ea23192e8e577dfc51e0f4fc5ca113af334edff9 ("tunnels:
Maybe add a Fixes tag?
=46ixes: ea23192e8e57 ("tunnels: harmonize cleanup done on skb on rx pa=
th")

> harmonize cleanup done on skb on rx path") broke anyone trying to
> use netfilter marking across IPv4 tunnels.  While most of the
> fields that are cleared by skb_scrub_packet don't matter, the
> netfilter mark must be preserved.
>
> This patch rearranges skb_scurb_packet to preserve the mark field.
nit: s/scurb/scrub

Else it's fine for me.
