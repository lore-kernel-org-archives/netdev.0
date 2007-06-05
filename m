From: Milton Miller <miltonm@bga.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100 rx: or s and el bits)
Date: Tue, 5 Jun 2007 12:56:27 -0500
Message-ID: <4112397f218a0744ebf8656c81acf850@bga.com>
References: <4654B2E4.9010308@roinet.com> <039d8ee49a8dfcbff8695b19d0a1a5c4@bga.com> <a4fae96e1c8c7b594207bf77fcb6b38f@bga.com> <465C4DBE.6000205@roinet.com> <94c8ff9069a77568513a9a1d1e60012d@bga.com> <4660856E.80403@roinet.com> <fac4512e243d821a94e8ee7304240981@bga.com> <4665664D.30906@roinet.com> <b2809ae38545c6104771af3c3a8b2250@bga.com> <46659CF7.2070003@intel.com> <20070605173904.GP31565@havoc.gtf.org> <4665A0B6.6020902@intel.com>
Mime-Version: 1.0 (Apple Message framework v624)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Jeff Garzik <jgarzik@pobox.com>,
	e1000-devel@lists.sourceforge.net, David Acker <dacker@roinet.com>,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Scott Feldman <sfeldma@pobox.com>,
	John Ronciak <john.ronciak@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mercury.realtime.net ([205.238.132.86]:45328 "EHLO
	ruth.realtime.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754962AbXFER4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 13:56:38 -0400
In-Reply-To: <4665A0B6.6020902@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Jun 5, 2007, at 12:43 PM, Kok, Auke wrote:

> Jeff Garzik wrote:
>> On Tue, Jun 05, 2007 at 10:27:19AM -0700, Kok, Auke wrote:
>>> We need to make sure that now that we're getting closer to 2.6.22 we 
>>> don't end up killing e100 in it. Should we drop the current fixes in 
>>> it to be on the safe side and aim for 2.6.23? I would hate to see an 
>>> untested codepath breaking e100 on something like ppc or mips... 
>>> that will be very painful
>> I certainly agree with this assessment...
>> I've been wondering if, based on all this recent work, we should 
>> revert
>> the s-bit stuff and wait for 2.6.23.
>
> Yes, that's my point. If Milton and David agree I think we should do 
> so immediately.

We definitely need something other than what is in now.


> If so, do you want me to write a revert-patch or do you have some 
> magic to do that for me?
>

The simple git revert won't work because there have been other changes 
(ioread for instance) that conflict.

milton

