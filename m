From: Sergey Lapin <slapin@ossfans.org>
Subject: Re: [PATCH 4/6] net: add NL802154 interface for configuration of
	802.15.4 devices
Date: Wed, 3 Jun 2009 16:55:07 +0400
Message-ID: <20090603125507.GA22673@build.ossfans.org>
References: <1244021629-18409-4-git-send-email-dbaryshkov@gmail.com> <1244021629-18409-5-git-send-email-dbaryshkov@gmail.com> <1244021964.10665.5.camel@johannes.local> <20090603.030911.162861804.davem@davemloft.net> <20090603105256.GB20508@doriath.ww600.siemens.net> <1244027110.1693.9.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, sfr@canb.auug.org.au
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from build.ossfans.org ([67.223.233.67]:34120 "EHLO
	build.ossfans.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836AbZFCMzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 08:55:40 -0400
Content-Disposition: inline
In-Reply-To: <1244027110.1693.9.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +#define IEEE802154_ATTR_MAX (__IEEE802154_ATTR_MAX - 1)
> > +#define NLA_HW_ADDR	NLA_U64
> > +#define NLA_GET_HW_ADDR(attr, addr) do { u64 _temp = nla_get_u64(attr); memcpy(addr, &_temp, 8); } while (0)
> > +#define NLA_PUT_HW_ADDR(msg, attr, addr) do { u64 _temp; memcpy(&_temp, addr, 8); NLA_PUT_U64(msg, attr, _temp); } while (0)

What would you propose here? adding prefix will add length to macro,
IEEE802154_NL_PUT_HW_ADDR is damn long name. Using repeated code
sequence is not better (it is error-prone and unreadable).

Any ideas?

