From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 08/12] ixgb: convert to new VLAN model
Date: Thu, 27 Jan 2011 14:18:28 +1000
Message-ID: <1296101908.2959.1.camel@localhost>
References: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1294360199-9860-9-git-send-email-jeffrey.t.kirsher@intel.com>
	 <AANLkTik1rCFRtBWov5f8yfU+4JZnbzLHgcmRC1y_+TDP@mail.gmail.com>
	 <EA929A9653AAE14F841771FB1DE5A136602DEE63CB@rrsmsx501.amr.corp.intel.com>
	 <AANLkTikS7zw5OfPFTJBUeUyy39Tx26Wkg9FX3n77-v1G@mail.gmail.com>
	 <EA929A9653AAE14F841771FB1DE5A136602DF59AA3@rrsmsx501.amr.corp.intel.com>
	 <AANLkTi=RU11ibzd3c9sqCLL0pNowvx1_ow7C=qWVoPMt@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bphilips@novell.com" <bphilips@novell.com>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:43345 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751910Ab1A0ESf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 23:18:35 -0500
In-Reply-To: <AANLkTi=RU11ibzd3c9sqCLL0pNowvx1_ow7C=qWVoPMt@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-01-26 at 19:53 -0800, Jesse Gross wrote:
> On Tue, Jan 25, 2011 at 10:20 AM, Tantilov, Emil S
> <emil.s.tantilov@intel.com> wrote:
[...]
> > Sure, but I think a savvy user would always check the result of an
> > ethtool command (ie. `ethtool -K` followed with `ethtool -k`, -A/-a,
> > etc).
> 
> Probably, but it seems the less savviness required from the user the
> better.  Regardless, it doesn't affect anything here, it would just be
> a change to the userspace tool.

I am intending to modify ethtool so that it will report any other
offload settings that were changed automatically.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

