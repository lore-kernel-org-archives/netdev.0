From: Russell Stuart <russell-tcatm@stuart.id.au>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Wed, 09 Aug 2006 08:01:16 +1000
Message-ID: <1155074476.4270.16.camel@ras.pc.brisbane.lube>
References: <1150278004.26181.35.camel@localhost.localdomain>
	 <1150286766.5233.15.camel@jzny2>
	 <1150287983.3246.27.camel@ras.pc.brisbane.lube>
	 <1150292693.5197.1.camel@jzny2>
	 <1150843471.17455.2.camel@ras.pc.brisbane.lube>
	 <15653CE98281AD4FBD7F70BCEE3666E53CD54A@comxexch01.comx.local>
	 <1151000966.5392.34.camel@jzny2>
	 <1151066247.4217.254.camel@ras.pc.brisbane.lube>
	 <1151158431.6716.95.camel@jzny2>
	 <1153188409.13145.5.camel@ras.pc.brisbane.lube>
	 <44BD56A4.9090002@andyfurniss.entadsl.com>
	 <1153270932.4242.60.camel@ras.pc.brisbane.lube>
	 <44BE46A6.8000207@trash.net>
	 <1153371364.4231.61.camel@ras.pc.brisbane.lube>
	 <1154300766.4236.5.camel@ras.pc.brisbane.lube>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lists@andyfurniss.entadsl.com,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 58.105.229.78.optusnet.com.au ([58.105.229.78]:42148 "EHLO
	adsl-kenny.stuart.id.au") by vger.kernel.org with ESMTP
	id S1030305AbWHHWCX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 18:02:23 -0400
To: hadi@cyberus.ca
In-Reply-To: <1154300766.4236.5.camel@ras.pc.brisbane.lube>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-07-31 at 09:06 +1000, Russell Stuart wrote:
> It has gone quiet again.  In my mind the one unresolved issue
> is whether Patrick intended to remove RTAB with his patch.
> If not, the ATM patch as it stands will have to go in.
> 
> Patrick - it would be nice to hear from you.

It appears Patrick isn't going to reply.  The situation as
I see it is:

- Patrick's last post said his STAB patch wasn't going to
  touch RTAB, so regardless of whether Patrick's STAB
  patch proceeds or not the ATM patch will be needed to
  make the current kernel work with ATM.

- If I read Jesper's last post correctly, he said Patrick
  acknowledged to him in a private email that RTAB had to 
  change to accommodate ATM, and in fact called it a bug
  in RTAB.  Fixing this "bug" is what the kernel part of
  the current ATM patch does - and it does it in a 
  backward compatible way.

- Jamal, you said that this ATM patch should go in if 
  Patrick didn't come up with a better solution.

Jamal - unless there are other outstanding issues I have 
missed or someone has had second thoughts this means you
should be OK with the patch going in.  Can we get it into
Dave M's tree now?

