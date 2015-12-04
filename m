From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 01/17] fm10k: Fix error handling in the function
 fm10k_setup_tc for certain function calls
Date: Thu, 03 Dec 2015 16:41:17 -0800
Message-ID: <1449189677.17296.24.camel@perches.com>
References: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1449188994-64940-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Nick <xerofoify@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0039.hostedemail.com ([216.40.44.39]:55632 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751610AbbLDAlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 19:41:20 -0500
In-Reply-To: <1449188994-64940-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-12-03 at 16:29 -0800, Jeff Kirsher wrote:
> From: Nick <xerofoify@gmail.com>

I guess this is an OK patch, but the From line isn't correct
(missing full name) and the changelog is nigh on unreadable.

> This fixes the function fm10k_setup_tc to properly check if the
> calls to either the function fm10k_init_queueing_scheme or the
> function fm10k_mbx_request_irq fail by returning a error code to
> signal that the call to either function has failed. Furthermore
> if this arises exit immediately from the function fm10k_setup_tc
> by returning the returned error code from the failed function call
> to signal to the caller that setting up the tc on the device has
> failed and the caller needs to handle this failed setup.

Maybe something like:

Add error handling in fm10k_setup_tc of fm10k_init_queueing_scheme
and fm10k_mbx_request_irq.
