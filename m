From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 12/18] ipw2200: version string rework
Date: Thu, 13 Apr 2006 10:28:20 -0700
Message-ID: <20060413102820.4fabf028@localhost.localdomain>
References: <20060413092034.GA28787@mail.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:36752 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932265AbWDMR2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 13:28:37 -0400
To: yi.zhu@intel.com
In-Reply-To: <20060413092034.GA28787@mail.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Apr 2006 17:20:34 +0800
Zhu Yi <yi.zhu@intel.com> wrote:

> Added version string fields so the version string indicates what is
> configured (ie, you'll see 1.1.1kpmd if you are using a GIT snapshot
> (Kernel.. previously -git), promiscuous (p), monitor (m), debug (d) build.

No, this is completely the wrong direction.

Stop with the config option nonsense. It makes it impossible for linux distributions
and others that want to ship one kernel and modules.

