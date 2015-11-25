From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 06/16] i40e: Properly cast type for arithmetic
Date: Tue, 24 Nov 2015 16:43:32 -0800
Message-ID: <1448412212.20113.12.camel@perches.com>
References: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1448409886-90686-7-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Helin Zhang <helin.zhang@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0090.hostedemail.com ([216.40.44.90]:51938 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755245AbbKYAng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 19:43:36 -0500
In-Reply-To: <1448409886-90686-7-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-24 at 16:04 -0800, Jeff Kirsher wrote:
> From: Helin Zhang <helin.zhang@intel.com>
> 
> Pointer of type void * shouldn't be used in arithmetic, which may
> result in compilation error. Casting of (u8 *) can be added to fix
> that.
> 

void * arithmetic is used quite frequently in the kernel.

What compiler emits an error?
