From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 4/5] AF_RXRPC: Key facility changes for AF_RXRPC [try #2]
Date: Fri, 16 Mar 2007 13:38:24 +0000
Message-ID: <20070316133824.GC2173@infradead.org>
References: <20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com> <20070316125031.3740.36610.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:47269 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753521AbXCPNi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 09:38:27 -0400
Content-Disposition: inline
In-Reply-To: <20070316125031.3740.36610.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 16, 2007 at 12:50:31PM +0000, David Howells wrote:
> Export the keyring key type definition.
> 
> Add extra alternative types into the key's type_data union to make it more
> useful.

You wrote the code so there must be some reason for this, but these
changes look rather odd to me :)

> diff --git a/security/keys/keyring.c b/security/keys/keyring.c
> index ad45ce7..88292e3 100644
> --- a/security/keys/keyring.c
> +++ b/security/keys/keyring.c
> @@ -66,6 +66,8 @@ struct key_type key_type_keyring = {
>  	.read		= keyring_read,
>  };
>  
> +EXPORT_SYMBOL(key_type_keyring);
> +

Having a type exported is really odd, how is this supposed to be a public API?
