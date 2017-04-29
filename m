From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] lwtunnel: fix error path in
 lwtunnel_fill_encap()
Date: Sat, 29 Apr 2017 07:03:07 -0600
Message-ID: <8e97609b-732b-9a84-b088-ba7f4384a1eb@cumulusnetworks.com>
References: <20170428130347.53hagk77wh6scmcs@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Robert Shearman <rshearma@brocade.com>,
        Tom Herbert <tom@herbertland.com>,
        David Lebrun <david.lebrun@uclouvain.be>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>,
        "David S. Miller" <davem@davemloft.net>,
        Pan Bian <bianpan2016@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:36730 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1166777AbdD2NDM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2017 09:03:12 -0400
Received: by mail-it0-f51.google.com with SMTP id r185so9096449itd.1
        for <netdev@vger.kernel.org>; Sat, 29 Apr 2017 06:03:12 -0700 (PDT)
In-Reply-To: <20170428130347.53hagk77wh6scmcs@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/28/17 7:03 AM, Dan Carpenter wrote:
> We recently added a check to see if nla_nest_start() fails.  There are
> two issues with that.  First, if it fails then I don't think we should
> call nla_nest_cancel().  Second, it's slightly convoluted but the
> current code returns success but we should return -EMSGSIZE instead.
> 
> Fixes: a50fe0ffd76f ("lwtunnel: check return value of nla_nest_start")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 

Acked-by: David Ahern <dsa@cumulusnetworks.com>
