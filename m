From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net 1/2] rds: tcp: use sock_create_lite() to create the
 accept socket
Date: Thu, 6 Jul 2017 09:43:50 -0700
Message-ID: <ff81c72f-0ce3-fbd7-1330-31151fa5198a@oracle.com>
References: <cover.1499352757.git.sowmini.varadhan@oracle.com>
 <6918d62064a34e62638f7bb47e4dcdf7de943549.1499352757.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:46943 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752442AbdGFQn3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 12:43:29 -0400
In-Reply-To: <6918d62064a34e62638f7bb47e4dcdf7de943549.1499352757.git.sowmini.varadhan@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/6/2017 8:15 AM, Sowmini Varadhan wrote:
> There are two problems with calling sock_create_kern() from
> rds_tcp_accept_one()
> 1. it sets up a new_sock->sk that is wasteful, because this ->sk
>     is going to get replaced by inet_accept() in the subsequent ->accept()
> 2. The new_sock->sk is a leaked reference in sock_graft() which
>     expects to find a null parent->sk
> 
> Avoid these problems by calling sock_create_lite().
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
