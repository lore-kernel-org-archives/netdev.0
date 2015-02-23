From: Stefan Assmann <sassmann@kpanic.de>
Subject: Re: [PATCH net-next] i40e: mark constant as ULL
Date: Mon, 23 Feb 2015 15:56:24 +0100
Message-ID: <54EB3F98.2030709@kpanic.de>
References: <1423050064-25087-1-git-send-email-sassmann@kpanic.de> <1423072177.2589.66.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from app1b.xlhost.de ([84.200.252.162]:40872 "EHLO app1b.xlhost.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752570AbbBWO4b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2015 09:56:31 -0500
In-Reply-To: <1423072177.2589.66.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04.02.2015 18:49, Jeff Kirsher wrote:
> On Wed, 2015-02-04 at 12:41 +0100, Stefan Assmann wrote:
>> This avoids a compile error on 32bit.
>>
>> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
>> ---
>>  drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Come to find out, I already have a fix in my queue for this.  So I will
> be dropping your patch.
> 
> The patch in my queue fixes the issue by doing the folling change:
> -               mask = 0xFFFFFFFFFFFFFFFF;
> +               mask = ~(u64)0;
> 

Jeff,

this does not seem to compile on 32bit either. Please verify and if
you agree let's put my patch back in place instead of this one. IIRC
your patch has not been posted yet.

  Stefan
