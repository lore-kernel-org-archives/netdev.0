From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Suspicious RCU from iwlwifi driver
Date: Fri, 11 Dec 2015 09:00:34 +0100
Message-ID: <1449820834.2324.0.camel@sipsolutions.net>
References: <566A0929.2090706@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Intel Linux Wireless <linuxwifi@intel.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Laura Abbott <labbott@redhat.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Avri Altman <avri.altman@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:59220 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752775AbbLKIAl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Dec 2015 03:00:41 -0500
In-Reply-To: <566A0929.2090706@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Laura,

> =C2=A0 drivers/net/wireless/intel/iwlwifi/mvm/sta.c:1226 suspicious
> rcu_dereference_protected() usage!

> If I revert 9513c5e18a0dc55a1fc9c890715098ba2315830b
> (iwlwifi: mvm: Avoid dereferencing sta if it was already flushed)
> The warning goes away. Known issue?

Thanks for the report - I at least hadn't seen this (or a fix for it)
yet, we'll take a look.

johannes
