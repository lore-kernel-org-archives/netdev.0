From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next] i40e: enable fdb add code, remove unused code
Date: Fri, 21 Nov 2014 08:50:46 +0100
Message-ID: <20141121075046.GC1872@nanopsycho.orion>
References: <1416529802-16055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:63265 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079AbaKUHuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 02:50:50 -0500
Received: by mail-wg0-f51.google.com with SMTP id k14so5694684wgh.38
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 23:50:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1416529802-16055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Nov 21, 2014 at 01:30:02AM CET, jeffrey.t.kirsher@intel.com wrote:
>From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>
>The original FDB code submission wasn't correct and the code
>wasn't enabled.  This removes some dead code (can use the common kernel
>code for fdb_del and fdb_dump) and correctly enables the fdb_add
>function pointer.
>
>The fdb_add functionality is important to i40e because it is needed
>for a workaround to allow bridges to work correctly on the i40e
>hardware.
>
>Reported-by: Jiri Pirko <jiri@resnulli.us>
>Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>Acked-by: Greg Rose <gregory.v.rose@intel.com>
>Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
