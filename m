From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [PATCH] xen-netback: don't de-reference vif pointer after
 having called xenvif_put()
Date: Tue, 11 Jun 2013 10:59:39 +0100
Message-ID: <51B7112B02000078000DD066@nat28.tlf.novell.com>
References: <51AF613F02000078000DB84E@nat28.tlf.novell.com>
 <20130611.020136.1037505762134627955.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:43515 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753646Ab3FKJ7l convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Tue, 11 Jun 2013 05:59:41 -0400
In-Reply-To: <20130611.020136.1037505762134627955.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 11.06.13 at 11:01, David Miller <davem@davemloft.net> wrote:
> From: "Jan Beulich" <JBeulich@suse.com>
> Date: Wed, 05 Jun 2013 15:03:11 +0100
> 
>> When putting vif-s on the rx notify list, calling xenvif_put() must be
>> deferred until after the removal from the list and the issuing of the
>> notification, as both operations dereference the pointer.
>> 
>> Changing this got me to notice that the "irq" variable was effectively
>> unused (and was of too narrow type anyway).
>> 
>> Signed-off-by: Jan Beulich <jbeulich@suse.com>
> 
> You've included the commit message, and the patch, twice.  Once inline
> and once as an attachment, do not do this.  It makes the patch impossible
> to apply when I fetch it out of patchwork.
> 
> Please submit it properly.

Sending to multiple lists makes it impossible to match everyone's
preferences/requirements. xen-devel generally wants patches
inline and attached (for the case where the inline variant gets
mangled by mail programs).

I'll resend inline only, in the hope that it'll reach your inbox intact.

Jan
