From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [net] e1000: Prevent reset task killing itself.
Date: Thu, 17 May 2012 06:40:06 -0700
Message-ID: <20120517134006.GB5380@kroah.com>
References: <1337252690-29687-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Tushar Dave <tushar.n.dave@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	stable@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:47236 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966485Ab2EQNkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 09:40:10 -0400
Received: by mail-pb0-f46.google.com with SMTP id rp8so2545519pbb.19
        for <netdev@vger.kernel.org>; Thu, 17 May 2012 06:40:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1337252690-29687-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 17, 2012 at 04:04:50AM -0700, Jeff Kirsher wrote:
> From: Tushar Dave <tushar.n.dave@intel.com>
> 
> Killing reset task while adapter is resetting causes deadlock.
> Only kill reset task if adapter is not resetting.
> Ref bug #43132 on bugzilla.kernel.org
> 
> CC: stable@vger.kernel.org
> Signed-off-by: Tushar Dave <tushar.n.dave@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
> @stable - this patch is applicable back to 3.1 kernels

In the future, so this information will not be lost, please do as
Documentation/stable_kernel_rules.txt show and put this information in
the cc: line to stable.  So for this patch, you should say:

 Cc: stable <stable@vger.kernel.org> [3.1+]
in the signed-off-by: area above.

thanks,

greg k-h
