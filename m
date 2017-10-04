From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] VSOCK: export __vsock_in_bound/connected_table()
Date: Tue, 03 Oct 2017 21:46:17 -0700 (PDT)
Message-ID: <20171003.214617.1472124119367144767.davem@davemloft.net>
References: <20171003153943.23159-1-stefanha@redhat.com>
        <20171003153943.23159-3-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhansen@vmware.com, decui@microsoft.com
To: stefanha@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33254 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750871AbdJDEqS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 00:46:18 -0400
In-Reply-To: <20171003153943.23159-3-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Hajnoczi <stefanha@redhat.com>
Date: Tue,  3 Oct 2017 11:39:40 -0400

> @@ -250,15 +250,17 @@ static struct sock *__vsock_find_connected_socket(struct sockaddr_vm *src,
>  	return NULL;
>  }
>  
> -static bool __vsock_in_bound_table(struct vsock_sock *vsk)
> +bool __vsock_in_bound_table(struct vsock_sock *vsk)
>  {
>  	return !list_empty(&vsk->bound_table);
>  }
> +EXPORT_SYMBOL_GPL(__vsock_in_bound_table);
>  
> -static bool __vsock_in_connected_table(struct vsock_sock *vsk)
> +bool __vsock_in_connected_table(struct vsock_sock *vsk)
>  {
>  	return !list_empty(&vsk->connected_table);
>  }
> +EXPORT_SYMBOL_GPL(__vsock_in_connected_table);

Maybe you can just make these inline helpers in af_vsock.h?
