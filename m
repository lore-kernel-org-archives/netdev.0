From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 16/17] mlxsw: spectrum_router: Abort on
 source-specific routes
Date: Wed, 19 Jul 2017 10:16:19 -0600
Message-ID: <a730169b-3f48-a232-0053-d2c40b5947e8@gmail.com>
References: <20170719070232.28457-1-jiri@resnulli.us>
 <20170719070232.28457-17-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        kafai@fb.com, hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:36799 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753530AbdGSQQV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 12:16:21 -0400
Received: by mail-pg0-f52.google.com with SMTP id 125so2251062pgi.3
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 09:16:20 -0700 (PDT)
In-Reply-To: <20170719070232.28457-17-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/19/17 1:02 AM, Jiri Pirko wrote:
> From: Ido Schimmel <idosch@mellanox.com>
> 
> Without resorting to ACLs, the device performs route lookup solely based
> on the destination IP address.
> 
> In case source-specific routing is needed, an error is returned and the
> abort mechanism is activated, thus allowing the kernel to take over
> forwarding decisions.
> 
> Instead of aborting, we can trap specific destination prefixes where
> source-specific routes are present, but this will result in a lot more
> code that is unlikely to ever be used.


Do you have a document summarizing these for users?
