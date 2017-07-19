From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 01/17] net: core: Make the FIB notification chain
 generic
Date: Wed, 19 Jul 2017 08:11:56 -0600
Message-ID: <50e59e23-cc6e-2e75-ddb8-9b8b5afc847d@gmail.com>
References: <20170719070232.28457-1-jiri@resnulli.us>
 <20170719070232.28457-2-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        kafai@fb.com, hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33947 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751400AbdGSOL7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 10:11:59 -0400
Received: by mail-pf0-f193.google.com with SMTP id o88so140965pfk.1
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 07:11:59 -0700 (PDT)
In-Reply-To: <20170719070232.28457-2-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/19/17 1:02 AM, Jiri Pirko wrote:
> +struct fib_notifier_ops *
> +fib_notifier_ops_register(const struct fib_notifier_ops *tmpl, struct net *net)
> +{
> +	struct fib_notifier_ops *ops;
> +	int err;
> +
> +	ops = kmemdup(tmpl, sizeof(*ops), GFP_KERNEL);

why allocate memory to copy the ops?
