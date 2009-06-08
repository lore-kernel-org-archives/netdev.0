From: David Miller <davem@davemloft.net>
Subject: Re: tun netns BUG()
Date: Mon, 08 Jun 2009 00:44:50 -0700 (PDT)
Message-ID: <20090608.004450.05570240.davem@davemloft.net>
References: <1244193463.3751.129.camel@macbook.infradead.org>
	<m1ljo61cya.fsf@fess.ebiederm.org>
	<1244271971.3751.968.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	johannes@sipsolutions.net
To: dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52755
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751067AbZFHHos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 03:44:48 -0400
In-Reply-To: <1244271971.3751.968.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Woodhouse <dwmw2@infradead.org>
Date: Sat, 06 Jun 2009 08:06:11 +0100

> On Fri, 2009-06-05 at 16:24 -0700, Eric W. Biederman wrote:
>> The patch below fixes the one bug I know of in with just my changes
>> applied.  I don't think it fixes everything with Herberts changes.
>> 
>> I expect some of this will need to be moved to release to fix the
>> select problem on 2.6.30-rc8.
> 
> It certainly seems to fix the BUG in unregister_netdevice() which was
> the failure mode I was seeing most often in 2.6.30-rc8. Thanks.
> 
> Tested-by: David Woodhouse <David.Woodhouse@intel.com>

Applied, thanks!
