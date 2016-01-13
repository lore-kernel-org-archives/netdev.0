From: Matti Vaittinen <matti.vaittinen@nokia.com>
Subject: Re: [PATCH 1/1] net: netlink: Fix multicast group storage allocation
 for families with more than one groups
Date: Wed, 13 Jan 2016 09:53:30 +0200
Message-ID: <20160113075330.GD26987@fi-ourus-dhcp00977.emea.nsn-net.net>
References: <20160111122610.GA28615@fi-ourus-dhcp00977.emea.nsn-net.net>
 <20160112.164211.956459588621139898.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes.berg@intel.com, jbenc@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, alexander.sverdlin@nokia.com,
	teppo.o.pennanen@nokia.com
To: EXT David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160112.164211.956459588621139898.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David & others,

On Tue, Jan 12, 2016 at 04:42:11PM -0500, EXT David Miller wrote:
> But I think your change has an off-by-one bug:
> 
> From: Matti Vaittinen <matti.vaittinen@nokia.com>
> > -		if (id >= mc_groups_longs * BITS_PER_LONG) {
> > +		if (id + n_groups >= mc_groups_longs * BITS_PER_LONG) {
> 
> I think this needs to be "id + n_groups > ".  Consider the existing,
> working, case of "n_groups == 1".  Now you're adding '1' and therefore
> the test needs to be adjusted from >= to >.

Absolutely. I did patch v2.

Br.
    Matti Vaittinen
