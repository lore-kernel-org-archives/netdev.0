From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with
 no group
Date: Thu, 27 Mar 2014 13:20:25 -0700
Message-ID: <CAHA+R7NY45pgO=5MjXQ_6WOW=32uMsV6vO1T2562VzezZLfUcA@mail.gmail.com>
References: <20140326094754.GA19337@zed>
	<OFD0C40ED9.015A05DD-ON87257CA2.003E72F3-87257CA2.003E7300@us.ibm.com>
	<CAF1J0HOd9D1t4hxjMe7Muad71o_pgKQsn3jLxqR5ZFPpj2_Nrw@mail.gmail.com>
	<CAJZOPZL9h0q3iiN7Q2jJWW+uEs0EpNaWqVMqQMyL+-5QGxGWPg@mail.gmail.com>
	<20140325.205324.1845346581147557473.davem@davemloft.net>
	<OF687EFECB.536163E6-ON87257CA7.00513C78-87257CA7.00513C81@us.ibm.com>
	<20140326175018.GA24065@zed>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <or.gerlitz@gmail.com>
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:63847 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756679AbaC0UU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 16:20:27 -0400
Received: by mail-lb0-f177.google.com with SMTP id z11so3016801lbi.36
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 13:20:25 -0700 (PDT)
In-Reply-To: <20140326175018.GA24065@zed>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2014 at 10:50 AM, Mike Rapoport
<mike.rapoport@ravellosystems.com> wrote:
>
> The problem is not only duplication of default destinations, but also
> the mis^Wuse of default_dst to distinguish whether IPv4 or IPv6 path
> should be taken because there is no explicit specification of the
> protocol if neither IFLA_VXLAN_GROUP or IFLA_VXLAN_LOCAL defined at
> vxlan_newlink. Moreover, if neither of these attributes is present, the
> custom configuration will always use v4 socket regardles of use of
> default_dst or fdb entry.

It should default to IPv4 for compatibility reason.
