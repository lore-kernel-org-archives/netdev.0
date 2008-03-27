From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 0/2] Two more pasemi_mac patches for 2.6.26
Date: Thu, 27 Mar 2008 15:41:19 -0400
Message-ID: <47EBF85F.6070200@pobox.com>
References: <20080326015625.GA23103@lixom.net> <47E9CD2E.7040203@pobox.com> <20080327192204.GA17881@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, pasemi-linux@ozlabs.org,
	netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33561 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757234AbYC0TlY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 15:41:24 -0400
In-Reply-To: <20080327192204.GA17881@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Olof Johansson wrote:
> On Wed, Mar 26, 2008 at 12:12:30AM -0400, Jeff Garzik wrote:
>> Olof Johansson wrote:
>>> Hi Jeff,
>>>
>>> The below two patches go on top of the previous patches that were acked
>>> by you but applied to pasemi.git for feed up through powerpc.git.
>>>
>>> One is a couple of fixes for various corner cases in the jumbo support
>>> configuration. The second is addition of netpoll support, from Nate
>>> Case.
>>>
>>> Review/ack would be appreciated, I'll feed them up the same path as the
>>> other changes.
>> ACK 1-2, though I would consider closely patch #2, whether you need 
>> disable_irq() or spin_lock_irqsave() -- which is best for your specific 
>> driver + platform?
> 
> I'm tempted to leave the disable/enable_irq() in there. It's certainly
> heavier than doing cpu-side irq masking, but adding a spinlock to the
> common interrupt path seems worse to me. I didn't think we considered
> the polling to be a hot path anyway...

Definitely not a hot path :)


