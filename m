From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 disable ASPM patch
Date: Thu, 3 Mar 2011 10:45:18 +0100
Message-ID: <20110303094518.GA13491@electric-eye.fr.zoreil.com>
References: <20110302.215255.183067695.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes <hayeswang@realtek.com>,
	sgruszka@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40315 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753055Ab1CCJt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 04:49:59 -0500
Content-Disposition: inline
In-Reply-To: <20110302.215255.183067695.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Hayes added to the Cc:)

David Miller <davem@davemloft.net> :
[...]
> What is the status of Stanislaw Gruszka's "disable ASPM" r8169
> patch?
> 
> 	http://patchwork.ozlabs.org/patch/83961/
> 
> Is it waiting for your testing ?

No.

I can test it against regression but I do not have the technical
knowledge to tell if it is right or not.

I have read (again) the PR as well as its sibling and there is little
evidence for me that the patch is 1) needed 2) better than the global
pcie_aspm switch. Either Realtek's in-house knowledge helps making
a technical decision or it is a policy-guided choice.

> Is it waiting for feedback from Hayes?

Yes.

Something like :
[ ] Ack. So far there is no way to handle ASPM reliably on the 816x
[ ] Not optimal but it is ok as an interim fix. For instance :
    - if some 816x (8168 ? 810{2, 3} ?) are known broken while others are not
    - it can be mitigated but the fix is not available yet
    - needs more tester / vendor work
    - etc.
[ ] Nak. The adequate fix is ...

> Is there going to be a MAINTAINERS patch that adds Hayes?  If so
> what is stalling that?

Realtek nic team asked me privately (end 2010) in rather general terms if
they could maintain the r8169 kernel driver. I have given some relevant
pointers for kernel code maintenance. Realtek did its housework.

I have stated publicly that I'll ack such a patch if Hayes wants to
add himself. Hayes was Cced. Either Hayes sends a patch or a plain
"please do it".

-- 
Ueimor
