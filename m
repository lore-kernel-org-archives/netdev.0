From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH RFC] iwlwifi: add basic runtime PM support
Date: Mon, 09 Jan 2012 10:10:16 +0100
Message-ID: <1326100216.3451.4.camel@jlt3.sipsolutions.net>
References: <4F065F59.2070107@intel.com>
	 <1325843269.3330.4.camel@jlt3.sipsolutions.net>
	 <4F0A3C62.6010403@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: wey-yi.w.guy@intel.com, ilw@linux.intel.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:36501 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753412Ab2AIJKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 04:10:21 -0500
In-Reply-To: <4F0A3C62.6010403@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-01-09 at 09:01 +0800, Yan, Zheng wrote:

> > NACK due to that last sentence. There's no way we can live with that in
> > the general case -- and your patch isn't even configurable afaict. And
> > I'm sure polling the rfkill flag would use just as much energy.
> > 
> It's configurable, runtime PM is disabled by default.

Oh ok, that's not so bad then -- we just need the default case to
continue working I think.

johannes
