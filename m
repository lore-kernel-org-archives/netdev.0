From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: examples to model ethernet driver off of?
Date: Wed, 13 Sep 2006 13:56:33 -0700
Message-ID: <45087081.5050400@intel.com>
References: <9F51F56C-9924-4DEC-A823-892DDEE69131@kernel.crashing.org> <20060913195445.GH25007@electric-eye.fr.zoreil.com> <450865DB.4040809@intel.com> <7E7667E8-DD25-4F31-AE27-C7C2E92AC622@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44575 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S1751190AbWIMU6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 16:58:05 -0400
To: Kumar Gala <galak@kernel.crashing.org>
In-Reply-To: <7E7667E8-DD25-4F31-AE27-C7C2E92AC622@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kumar Gala wrote:
> 
> On Sep 13, 2006, at 3:11 PM, Auke Kok wrote:
> 
>> Francois Romieu wrote:
>>> Kumar Gala <galak@kernel.crashing.org> :
>>>> What are good examples of simple/basic ethernet drivers one should  
>>>> use to model a new driver off of?
>>> tg3/bnx2/sky2/b44/8139cp
>>
>> Can I add e1000/ixgb to that? ;)
> 
> What is the feeling about e100.c?

e100 is a rather simple driver because the hardware doesn't support much 
features. We've tried to make e100 a bit more like e1000 over the last few 
years as in basic structure, and as such e1000 is always a bit ahead of e100 
when it comes to that. Nonetheless it's probably an easy driver to read 
codewise (I should hope).

Cheers,

Auke
