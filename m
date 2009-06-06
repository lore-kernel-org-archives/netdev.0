From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: tun netns BUG()
Date: Sat, 06 Jun 2009 08:06:11 +0100
Message-ID: <1244271971.3751.968.camel@macbook.infradead.org>
References: <1244142352.3751.14.camel@macbook.infradead.org>
	 <m17hzr7a0o.fsf@fess.ebiederm.org>
	 <1244191328.3751.111.camel@macbook.infradead.org>
	 <1244193463.3751.129.camel@macbook.infradead.org>
	 <m1ljo61cya.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:52614 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbZFFHGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jun 2009 03:06:12 -0400
In-Reply-To: <m1ljo61cya.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-06-05 at 16:24 -0700, Eric W. Biederman wrote:
> The patch below fixes the one bug I know of in with just my changes
> applied.  I don't think it fixes everything with Herberts changes.
> 
> I expect some of this will need to be moved to release to fix the
> select problem on 2.6.30-rc8.

It certainly seems to fix the BUG in unregister_netdevice() which was
the failure mode I was seeing most often in 2.6.30-rc8. Thanks.

Tested-by: David Woodhouse <David.Woodhouse@intel.com>

-- 
dwmw2

