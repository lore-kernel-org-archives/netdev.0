From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netback: don't de-reference vif pointer after
 having called xenvif_put()
Date: Tue, 11 Jun 2013 13:00:31 -0700 (PDT)
Message-ID: <20130611.130031.1750535297426864390.davem@davemloft.net>
References: <51AF613F02000078000DB84E@nat28.tlf.novell.com>
	<20130611.020136.1037505762134627955.davem@davemloft.net>
	<51B7112B02000078000DD066@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, xen-devel@lists.xen.org,
	netdev@vger.kernel.org
To: JBeulich@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44847 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574Ab3FKUAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 16:00:35 -0400
In-Reply-To: <51B7112B02000078000DD066@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jan Beulich" <JBeulich@suse.com>
Date: Tue, 11 Jun 2013 10:59:39 +0100

>>>> On 11.06.13 at 11:01, David Miller <davem@davemloft.net> wrote:
>> From: "Jan Beulich" <JBeulich@suse.com>
>> Date: Wed, 05 Jun 2013 15:03:11 +0100
>> 
>>> When putting vif-s on the rx notify list, calling xenvif_put() must be
>>> deferred until after the removal from the list and the issuing of the
>>> notification, as both operations dereference the pointer.
>>> 
>>> Changing this got me to notice that the "irq" variable was effectively
>>> unused (and was of too narrow type anyway).
>>> 
>>> Signed-off-by: Jan Beulich <jbeulich@suse.com>
>> 
>> You've included the commit message, and the patch, twice.  Once inline
>> and once as an attachment, do not do this.  It makes the patch impossible
>> to apply when I fetch it out of patchwork.
>> 
>> Please submit it properly.
> 
> Sending to multiple lists makes it impossible to match everyone's
> preferences/requirements. xen-devel generally wants patches
> inline and attached (for the case where the inline variant gets
> mangled by mail programs).

That's rediculous.  Fix your mail client setup, and send it inline
only.

Otherwise people can't reply and comment inline to the content of
your patch properly.
