From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: ipv6 udp early demux breaks udp_l3mdev_accept=0
Date: Sun, 16 Apr 2017 17:26:47 -0600
Message-ID: <3639a683-2839-4363-2cd2-c2a040402c93@cumulusnetworks.com>
References: <0c7198e6-7dde-917b-9c10-4e1835e38319@cumulusnetworks.com>
 <479839ac1ff57240a61f43d7b128a2a3@codeaurora.org>
 <1f3828b5-6fce-ac9c-6be0-80352aef06de@cumulusnetworks.com>
 <20170415.094810.1393827754237126920.davem@davemloft.net>
 <2b582c01f3d2e265cf94bc89d0346a5b@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        rshearma@brocade.com
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35901 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932134AbdDPX0u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Apr 2017 19:26:50 -0400
Received: by mail-pg0-f42.google.com with SMTP id g2so64037025pge.3
        for <netdev@vger.kernel.org>; Sun, 16 Apr 2017 16:26:50 -0700 (PDT)
In-Reply-To: <2b582c01f3d2e265cf94bc89d0346a5b@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/15/17 8:23 PM, Subash Abhinov Kasiviswanathan wrote:
>>> It should be fixed for 4.12. Basically, __udp6_lib_demux_lookup needs to
>>> be more like __udp4_lib_demux_lookup
> 
> Hi David
> 
> Would it be possible for you to test this with udp_l3mdev_accept=0

formatting was botched so it does not apply cleanly. please send a patch
file
