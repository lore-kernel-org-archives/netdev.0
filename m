From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH iproute2 json v2 05/27] ip: ipaddress.c: add support for
 json output
Date: Wed, 20 Sep 2017 15:33:58 +0200
Message-ID: <20170920133358.GA1073@bistromath.localdomain>
References: <20170817173614.54987-1-julien@cumulusnetworks.com>
 <20170817173614.54987-6-julien@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, dsa@cumulusnetworks.com
To: Julien Fortin <julien@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60435 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750892AbdITNeD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 09:34:03 -0400
Content-Disposition: inline
In-Reply-To: <20170817173614.54987-6-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Julien,

2017-08-17, 10:35:52 -0700, Julien Fortin wrote:
> From: Julien Fortin <julien@cumulusnetworks.com>
> 
> This patch converts all output (mostly fprintfs) to the new ip_print api
> which handle both regular and json output.
> Initialize a json_writer and open an array object if -json was specified.
> Note that the JSON attribute naming follows the NETLINK_ATTRIBUTE naming.
[snip]

This patch (commit d0e720111aad) changed the output of "ip addr":

Before:
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever

After:
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128scope host 
       valid_lft forever preferred_lft forever

The space following the mask is missing.

Could you have a look?
Thanks.

-- 
Sabrina
