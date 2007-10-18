From: Jeff Garzik <jeff@garzik.org>
Subject: Re: broken PCNET32 in 2.6.24 requires experimental PCNET32_NAPI?
Date: Thu, 18 Oct 2007 16:58:50 -0400
Message-ID: <4717C90A.4060208@garzik.org>
References: <200710182054.l9IKsiQJ007446@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, pcnet32@verizon.net,
	netdev@vger.kernel.org
To: Erez Zadok <ezk@cs.sunysb.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60791 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754846AbXJRU6w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2007 16:58:52 -0400
In-Reply-To: <200710182054.l9IKsiQJ007446@agora.fsl.cs.sunysb.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Erez Zadok wrote:
> I'm using Linus's git tree as of commit
> d85714d81cc0408daddb68c10f7fd69eafe7c213.  I built that kernel under vmware
> workstation 6.0.1 which emulates a pcnet32 nic.  When I only turn on
> CONFIG_PCNET32, my network interface doesn't seem to come up fully: my dhcp
> server sees a request, offers an IP addr, but the VM running 2.6.24 doesn't
> pick up the response.  Manually configuring the eth0 and pinging yields
> similar results: no replies come back.  The same VM has lots of other
> kernels on it, all of which work fine (so it's not an iptables/selinux
> problem, or the like).
> 
> If, however, I turn on the EXPERIMENTAL feature CONFIG_PCNET32_NAPI, then
> the driver works again.  So, is this NAPI feature now a required one or did
> the base driver somehow got broken?  I've not investigated this further.

Fixes were posted by the maintainer, and pushed to Linus, yesterday...

	Jeff



