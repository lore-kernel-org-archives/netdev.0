From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ixgb: Convert to new vlan model.
Date: Tue, 14 Dec 2010 21:47:11 +0000
Message-ID: <1292363231.20458.25.camel@bwh-desktop>
References: <1292298163-30343-1-git-send-email-jesse@nicira.com>
	 <1292344315.20458.6.camel@bwh-desktop>
	 <EA929A9653AAE14F841771FB1DE5A136602D675056@rrsmsx501.amr.corp.intel.com>
	 <1292350359.20458.8.camel@bwh-desktop>
	 <EA929A9653AAE14F841771FB1DE5A136602D6751C1@rrsmsx501.amr.corp.intel.com>
	 <1292354121.20458.11.camel@bwh-desktop>
	 <AANLkTimnSedKQhhL8xXQVKnEm3FpbfRQ_Nd9hPmGbHLJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:29547 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757556Ab0LNVrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 16:47:15 -0500
In-Reply-To: <AANLkTimnSedKQhhL8xXQVKnEm3FpbfRQ_Nd9hPmGbHLJ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-12-14 at 13:29 -0800, Jesse Gross wrote:
> On Tue, Dec 14, 2010 at 11:15 AM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> > On Tue, 2010-12-14 at 12:08 -0700, Tantilov, Emil S wrote:
> >> Ben Hutchings wrote:
> >> > On Tue, 2010-12-14 at 11:09 -0700, Tantilov, Emil S wrote:
> >> >> Ben Hutchings wrote:
> >> >>> On Mon, 2010-12-13 at 19:42 -0800, Jesse Gross wrote:
[...]
> >> >>> I think this should reject attempts to change just one flag with
> >> >>> -EINVAL, rather than quietly 'fixing' the setting.
[...]
> Ben, I agree that limiting the settings to what is actually supported
> is conceptually cleaner but in practice it's not very intuitive.  If
> you try to turn something off and the response is that it's invalid,
> most people are going to assume that you just can't do it.  This is
> especially true since you actually can't turn these settings off in
> most drivers.
> 
> There's a precedent for this type of thing: turn off TX checksum
> offloading and watch scatter/gather and TSO be automatically disabled
> as well.  It makes sense - the user requested a change, we do what is
> necessary to make that happen without requiring them to understand why
> these features are interrelated.

That reflects a general dependency and not a driver- or hardware-
specific restriction.  But I see your point.

Perhaps the ethtool utility should check the result after applying
offload changes and report any additional automatic changes.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

