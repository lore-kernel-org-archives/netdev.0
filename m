From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH RFC] iwlwifi: add basic runtime PM support
Date: Mon, 09 Jan 2012 10:11:10 +0100
Message-ID: <1326100270.3451.5.camel@jlt3.sipsolutions.net>
References: <4F065F59.2070107@intel.com>
	 <1325843269.3330.4.camel@jlt3.sipsolutions.net>
	 <4F0A3C62.6010403@intel.com> <1326069251.13074.360.camel@wwguy-huron>
	 <4F0A492A.5080504@intel.com>  <1326071127.13074.367.camel@wwguy-huron>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Yan, Zheng" <zheng.z.yan@intel.com>, ilw@linux.intel.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: "Guy, Wey-Yi" <wey-yi.w.guy@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:36506 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753412Ab2AIJLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 04:11:14 -0500
In-Reply-To: <1326071127.13074.367.camel@wwguy-huron>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-01-08 at 17:05 -0800, Guy, Wey-Yi wrote:


> I understand, but unless we figure out either make rkill interrupt works
> in runtime PM, or figure out the platform does not has HW RFKILL
> automatically, I don't see how this patch can upstream without generate
> a lot of issues and bug reports.

I suppose the question is -- will any tools/users enable it and then
scream about their rfkill?

Maybe we can use pm_runtime_forbid() to disable it completely, and add a
module parameter or something to enable it -- just so people are aware
of the tradeoffs?

johannes
