From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [Intel-wired-lan] [PATCH] intel: i40e: virtchnl: fix incorrect
 variable assignment
Date: Thu, 15 Jun 2017 16:07:40 -0500
Message-ID: <20170615160740.Horde.Jp_M9DTPyKHhri-Ff7J7hSX@gator4166.hostgator.com>
References: <20170615023826.GA8136@embeddedgus>
 <20170615135033.00001ecf@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org, linux-kernel@vger.kernel.org
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway30.websitewelcome.com ([192.185.150.24]:21971 "EHLO
        gateway30.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751755AbdFOVHn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 17:07:43 -0400
Received: from cm15.websitewelcome.com (cm15.websitewelcome.com [100.42.49.9])
        by gateway30.websitewelcome.com (Postfix) with ESMTP id D9C4425AD6
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 16:07:40 -0500 (CDT)
In-Reply-To: <20170615135033.00001ecf@intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesse,

Quoting Jesse Brandeburg <jesse.brandeburg@intel.com>:

> On Wed, 14 Jun 2017 21:38:26 -0500
> "Gustavo A. R. Silva" <garsilva@embeddedor.com> wrote:
>
>> Fix incorrect variable assignment.
>> Based on line 1511: aq_ret = I40_ERR_PARAM; the correct variable to be
>> used in this instance is aq_ret instead of ret. Also, variable ret is
>> updated at line 1602 just before return, so assigning a value to this
>> variable in this code block is useless.
>>
>> Addresses-Coverity-ID: 1397693
>> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
>
> Thanks for the fix, looks reasonable.
> Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

Absolutely, glad to help.

Regards
