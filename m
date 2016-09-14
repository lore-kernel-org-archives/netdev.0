From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [net v1] fib_rules: interface group matching
Date: Wed, 14 Sep 2016 08:15:21 -0600
Message-ID: <9540c014-78c5-9f9c-16d7-75a564f6c018@cumulusnetworks.com>
References: <20160914124025.13417-1-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Vincent Bernat <vincent@bernat.im>,
        "David S. Miller" <davem@davemloft.net>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Wilson Kok <wkok@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:36194 "EHLO
        mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755219AbcINOPZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 10:15:25 -0400
Received: by mail-it0-f48.google.com with SMTP id o3so46342561ita.1
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 07:15:24 -0700 (PDT)
In-Reply-To: <20160914124025.13417-1-vincent@bernat.im>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/14/16 6:40 AM, Vincent Bernat wrote:
> When a user wants to assign a routing table to a group of incoming
> interfaces, the current solutions are:
> 
>  - one IP rule for each interface (scalability problems)
>  - use of fwmark and devgroup matcher (don't work with internal route
>    lookups, used for example by RPF)
>  - use of VRF devices (more complex)

Why do you believe that? A VRF is a formalized grouping of interfaces that includes an API for locally generated traffic to specify which VRF/group to use. And, with the l3mdev rule you only need 1 rule for all VRFs regardless of the number which is the best solution to the scalability problem of adding rules per device/group/VRF.

What use case are trying to solve?
