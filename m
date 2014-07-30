From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: FW: ethtool patch to support bypass / fail-to-wire function
Date: Thu, 31 Jul 2014 00:03:43 +0200
Message-ID: <20140730220343.GA309@electric-eye.fr.zoreil.com>
References: <3BFAEADE799AF145974162DF00E013AF018F794DE5@exchange2010.silicom.local>
 <1402322812.23860.76.camel@deadeye.wl.decadent.org.uk>
 <3BFAEADE799AF145974162DF00E013AF018F798C22@exchange2010.silicom.local>
 <20140611091757.78e1002d@nehalam.linuxnetplumber.net>
 <3BFAEADE799AF145974162DF00E013AF018F79A137@exchange2010.silicom.local>
 <20140611113558.6d0c6296@nehalam.linuxnetplumber.net>
 <3BFAEADE799AF145974162DF00E013AF018F803DED@exchange2010.silicom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Anna Lukin <annal@silicom.co.il>
To: David Hendel <david@silicom.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:56563 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548AbaG3WDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 18:03:47 -0400
Content-Disposition: inline
In-Reply-To: <3BFAEADE799AF145974162DF00E013AF018F803DED@exchange2010.silicom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Hendel <david@silicom.co.il> :
[...]
> We have our bypass driver updated and we would like to move forward with
> integrating it into the kernel.
> We think it need to be under drivers/net/
> 
> The description is per the below, taken from readme in linux.
> The patch is attached,
> Let me know how we can proceed with that. what should be the next step.

Executive summary: this code does not even remotely look like network
kernel code. The patch completely messes code that had been reworked
in drivers/staging.

It's very embarrassing.

-- 
Ueimor
