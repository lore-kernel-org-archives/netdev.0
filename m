From: Andreas =?iso-8859-1?Q?H=FCbner?= <andreas@k4n.de>
Subject: Re: icmpv6: issue with routing table entries from link local
 addresses
Date: Tue, 13 Sep 2016 13:59:18 +0200
Message-ID: <20160913115918.GL26782@targo.k4n.de>
References: <20160912142732.GI26782@targo.k4n.de>
 <b6804e09-403f-64ff-257b-6c5fda7f8047@stressinduktion.org>
 <bf36b487-1cdf-ede9-1ed8-cca17c7f5fc6@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from targo.k4n.de ([213.133.103.195]:45914 "EHLO targo.k4n.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751044AbcIML70 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 07:59:26 -0400
Content-Disposition: inline
In-Reply-To: <bf36b487-1cdf-ede9-1ed8-cca17c7f5fc6@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think I found the relevant fixes:

First and foremost it's 741a11d9e410.
(net: ipv6: Add RT6_LOOKUP_F_IFACE flag if oif is set)

This seems to have already solved my problem, however there were two
followup fixes that I should probably also apply:

d46a9d678e4c net: ipv6: Dont add RT6_LOOKUP_F_IFACE flag if saddr set
6f21c96a78b8 ipv6: enforce flowi6_oif usage in ip6_dst_lookup_tail()


So again, sorry for the noise and thanks for your help!

Andreas
