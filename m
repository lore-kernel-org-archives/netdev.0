From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] i40e: remove dead fdb code
Date: Fri, 21 Nov 2014 08:44:01 +0100
Message-ID: <20141121074401.GB1872@nanopsycho.orion>
References: <1416489029-1929-1-git-send-email-jiri@resnulli.us>
 <20141120093946.00000d30@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	linux.nics@intel.com, e1000-devel@lists.sourceforge.net
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:34029 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805AbaKUHoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 02:44:04 -0500
Received: by mail-wi0-f176.google.com with SMTP id ex7so11079664wid.15
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 23:44:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141120093946.00000d30@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Nov 20, 2014 at 06:39:46PM CET, jesse.brandeburg@intel.com wrote:
>On Thu, 20 Nov 2014 14:10:29 +0100
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> This code is not used now and also it contains some weird ifdefs. So
>> remove it for now. It can be added when needed.
>> 
>
>First, thanks for looking at our code.
>
>but, NAK, the code just needs to have the #ifdefs removed.
>
>In addition the fdb_del and fdb_dump functions are un-necessary and
>were submitted by mistake.

So it need more than ifdefs removal. That's what I thought :)

>
>I will draft up a patch today and send it (and Jeff can take it through
>Jeff Kirsher's i40e tree, if thats okay with DaveM)
>
>Thanks, 
> Jesse
