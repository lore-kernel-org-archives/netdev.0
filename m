From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: change fib behavior based on interface
 link status
Date: Wed, 3 Jun 2015 14:27:18 -0400
Message-ID: <20150603182718.GK588@gospo.home.greyhouse.net>
References: <1433300839-18511-1-git-send-email-gospo@cumulusnetworks.com>
 <CAE4R7bD6eZGR2k-CMUhCrYhpH7sgCHCaAZ=7u1ot1j4TQGPVgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:33584 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932475AbbFCS1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 14:27:21 -0400
Received: by qcmi9 with SMTP id i9so7959961qcm.0
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 11:27:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bD6eZGR2k-CMUhCrYhpH7sgCHCaAZ=7u1ot1j4TQGPVgA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2015 at 11:15:55AM -0700, Scott Feldman wrote:
> On Tue, Jun 2, 2015 at 8:07 PM, Andy Gospodarek
> <gospo@cumulusnetworks.com> wrote:
> > This feature is only enabled with the new sysctl set (default is off):
> > net.core.kill_routes_on_linkdown = 1
> 
> One more thing, sorry.  This feature is typically implemented today in
> user-space on a per-interface basis.  The example I'm thinking of is
> Quagga's "link-detect" directive which goes on an interface.  Should
> this be a bool on each interface in systcl?  That would let user not
> enable on selected interfaces.
That would not be my preference.

I'm willing to investigate the per-namespace support if Hannes would
like and add switchdev support for v2, but would prefer this not become
that granular.
