From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next v5 1/2] ethtool: add speed/duplex validation
 functions
Date: Thu, 4 Feb 2016 14:18:36 +0200
Message-ID: <20160204121836.GA5864@redhat.com>
References: <1454468677-12280-1-git-send-email-razor@blackwall.org>
 <1454468677-12280-2-git-send-email-razor@blackwall.org>
 <20160204103226.333d98ca@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nikolay Aleksandrov <razor@blackwall.org>, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46949 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755372AbcBDMSj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 07:18:39 -0500
Content-Disposition: inline
In-Reply-To: <20160204103226.333d98ca@samsung9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 04, 2016 at 10:32:26AM +1100, Stephen Hemminger wrote:
> On Wed,  3 Feb 2016 04:04:36 +0100
> Nikolay Aleksandrov <razor@blackwall.org> wrote:
> 
> >  
> > +static inline int ethtool_validate_speed(__u32 speed)
> > +{
> 
> 
> No need for inline.
> 
> But why check for valid value at all. At some point in the
> future, there will be yet another speed adopted by some standard body
> and the switch statement would need another value.
> 
> Why not accept any value? This is a virtual device.

It's virtual but often there's a physical backend behind it.  In the
future we will likely forward the values to and from that physical
device.  And if guest passes an unexpected value, host is unlikely to be
able to support it.

-- 
MST
