From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v2 3/5] tc/q_netem: Don't dereference possibly
 NULL pointer
Date: Fri, 18 Aug 2017 09:25:45 -0700
Message-ID: <20170818092545.1aabc809@xeon-e3>
References: <20170817170931.24545-1-phil@nwl.cc>
        <20170817170931.24545-4-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:36592 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750913AbdHRQZs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 12:25:48 -0400
Received: by mail-pg0-f47.google.com with SMTP id i12so67461142pgr.3
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 09:25:48 -0700 (PDT)
In-Reply-To: <20170817170931.24545-4-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Aug 2017 19:09:29 +0200
Phil Sutter <phil@nwl.cc> wrote:

> @@ -546,6 +546,8 @@ static int netem_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
>  	if (opt == NULL)
>  		return 0;
>  
> +	len = RTA_PAYLOAD(opt) - sizeof(qopt);
> +
>  	if (len < 0) {

Dont add blank line between computation and conditional.
Having them together reads better.
