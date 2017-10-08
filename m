From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: devlink dump of mlxsw_adj table triggers a panic
Date: Sun, 8 Oct 2017 09:04:45 -0600
Message-ID: <020bd536-7bae-5a6d-ea0e-17f7bca5980f@cumulusnetworks.com>
References: <78e0bce8-e122-ab92-2f48-e9d278f4d2b4@cumulusnetworks.com>
 <c7286c2b-09de-1221-303a-0aed3ed77c21@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Arkadi Sharshevsky <arkadis@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:54590 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751027AbdJHPEp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Oct 2017 11:04:45 -0400
Received: by mail-pf0-f177.google.com with SMTP id m28so6637808pfi.11
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 08:04:45 -0700 (PDT)
In-Reply-To: <c7286c2b-09de-1221-303a-0aed3ed77c21@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/8/17 1:43 AM, Arkadi Sharshevsky wrote:
> Thanks, will check it out. How many nexthops groups & overall number of
> nexthops you configured?

8 ports with 62 VLANs on each (496 total vlan devices) and 62 VRFs. BGP
is exchanging routes with neighbors. No multipath routes.
