From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] XFRM: SPD auditing fix to include the netmask/prefix-length
Date: Fri, 30 Nov 2007 09:51:48 -0500
Message-ID: <200711300951.48964.paul.moore@hp.com>
References: <20071126195512.6176.10448.stgit@flek.americas.hpqcorp.net> <20071129103459.GD22537@gondor.apana.org.au> <200711290845.46623.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: linux-audit@redhat.com, Joy Latten <latten@us.ibm.com>,
	Steve Grubb <sgrubb@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:15501 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757772AbXK3Owf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2007 09:52:35 -0500
In-Reply-To: <200711290845.46623.paul.moore@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 29 November 2007 8:45:46 am Paul Moore wrote:
> On Thursday 29 November 2007 5:34:59 am Herbert Xu wrote:
> > On Mon, Nov 26, 2007 at 07:55:12PM +0000, Paul Moore wrote:
> > > Currently the netmask/prefix-length of an IPsec SPD entry is not
> > > included in any of the SPD related audit messages.  This can cause a
> > > problem when the audit log is examined as the netmask/prefix-length is
> > > vital in determining what network traffic is affected by a particular
> > > SPD entry. This patch fixes this problem by adding two additional
> > > fields, "src_prefixlen" and "dst_prefixlen", to the SPD audit messages
> > > to indicate the source and destination netmasks.  These new fields are
> > > only included in the audit message when the netmask/prefix-length is
> > > less than the address length, i.e. the SPD entry applies to a network
> > > address and not a host address.
> >
> > Any reason why we don't just always include them?
>
> The audit folks seem to be very sensitive to the size/length of the audit
> messages, they prefer they be as small as possible.  I thought that one way
> to save space would be to only print the prefix length information when the
> address referred to a network and not a single host.
>
> Would you prefer it if the prefix length information was always included in
> the audit message?  Joy?  Audit folks?

Steve and/or Joy, could we get a verdict on this issue?  The lack of a netmask 
in the SPD audit messages is pretty serious so I'd like to see this fixed as 
soon as possible.

-- 
paul moore
linux security @ hp
