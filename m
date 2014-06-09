From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 01/13] i40e: add checks for AQ error status bits
Date: Mon, 09 Jun 2014 14:18:30 -0700
Message-ID: <1402348710.3142.29.camel@joe-AO725>
References: <1402303758-1429-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1402303758-1429-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <5395B4C1.7070004@cogentembedded.com>
	 <1402346114.2183.5.camel@jtkirshe-mobl.jf.intel.com>
	 <1402347725.3142.19.camel@joe-AO725>
	 <1402348238.2183.10.camel@jtkirshe-mobl.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	davem@davemloft.net, Shannon Nelson <shannon.nelson@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0195.hostedemail.com ([216.40.44.195]:46018 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753837AbaFIVSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 17:18:35 -0400
In-Reply-To: <1402348238.2183.10.camel@jtkirshe-mobl.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-06-09 at 14:10 -0700, Jeff Kirsher wrote:
> Well, as Shannon noted in the patch description:
> "If the Firmware sets these bits, it will trigger an AdminQ
> interrupt to get the driver's attention to process the ARQ, which will
> likely be enough to clear the actual issue."

Yeah, I quoted that too.

> To me that means the log messages should not be filling up with these
> types of messages and if they do occur, it should be transient and
> resolve itself.  So does that warrant dev_dbg? 

No idea.  That's up to you.  They're your messages.

I guess it depends on what you expect your users to
do when these are emitted.
