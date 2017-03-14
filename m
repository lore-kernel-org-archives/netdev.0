From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH net-next 0/4] gtp: support multiple APN's per GTP
 endpoint
Date: Tue, 14 Mar 2017 13:42:44 +0100 (CET)
Message-ID: <2005226672.385248.1489495364893.JavaMail.zimbra@tpip.net>
References: <20170314112548.24027-1-aschultz@tpip.net> <20170314114538.GC2992@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: laforge <laforge@gnumonks.org>,
        osmocom-net-gprs <osmocom-net-gprs@lists.osmocom.org>,
        netdev <netdev@vger.kernel.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>
To: pablo <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:57446 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750795AbdCNMms (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Mar 2017 08:42:48 -0400
In-Reply-To: <20170314114538.GC2992@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- On Mar 14, 2017, at 12:45 PM, pablo pablo@netfilter.org wrote:

> On Tue, Mar 14, 2017 at 12:25:44PM +0100, Andreas Schultz wrote:
> [...]
>> API impact:
>> -----------
>> 
>> This is probably the most problematic part of this series...
>> 
>> The removeal of the TEID form the netdevice also means that the gtp genl API
>> for retriving tunnel information and removing tunnels needs to be adjusted.
>> 
>> Before this change it was possible to change a GTP tunnel using the gtp
>> netdevice id and the teid. The teid is no longer unique per gtp netdevice.
>> After this change it has to be either the netdevice and MS IP or the GTP
>> socket and teid.
> 
> Then we have to introduce some explicit VRF concept or such to sort
> out this.
> 
> It is definitely not acceptable to break the existing API.

The specific use case of the API that is no longer supported was never used by
anyone. The only supported and documented API for the GTP module is libgtpnl.
libgtpnl has always required the now mandatory fields. Therefor the externally
supported API does not change.

Regards
Andreas
