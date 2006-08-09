From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Wed, 09 Aug 2006 07:33:41 -0400
Message-ID: <1155123221.5130.23.camel@jzny2>
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
	 <1155074476.4270.16.camel@ras.pc.brisbane.lube>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lists@andyfurniss.entadsl.com,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:15503 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1030699AbWHILdp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 07:33:45 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GAmJn-0004F2-F2
	for netdev@vger.kernel.org; Wed, 09 Aug 2006 07:33:47 -0400
To: Russell Stuart <russell-tcatm@stuart.id.au>
In-Reply-To: <1155074476.4270.16.camel@ras.pc.brisbane.lube>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-09-08 at 08:01 +1000, Russell Stuart wrote:
> On Mon, 2006-07-31 at 09:06 +1000, Russell Stuart wrote:
> > It has gone quiet again.  In my mind the one unresolved issue
> > is whether Patrick intended to remove RTAB with his patch.
> > If not, the ATM patch as it stands will have to go in.
> > 
> > Patrick - it would be nice to hear from you.
> 
> It appears Patrick isn't going to reply.  The situation as
> I see it is:
> 
> - Patrick's last post said his STAB patch wasn't going to
>   touch RTAB, so regardless of whether Patrick's STAB
>   patch proceeds or not the ATM patch will be needed to
>   make the current kernel work with ATM.
> 
> - If I read Jesper's last post correctly, he said Patrick
>   acknowledged to him in a private email that RTAB had to 
>   change to accommodate ATM, and in fact called it a bug
>   in RTAB.  Fixing this "bug" is what the kernel part of
>   the current ATM patch does - and it does it in a 
>   backward compatible way.
> 
> - Jamal, you said that this ATM patch should go in if 
>   Patrick didn't come up with a better solution.
> 
> Jamal - unless there are other outstanding issues I have 
> missed or someone has had second thoughts this means you
> should be OK with the patch going in.  Can we get it into
> Dave M's tree now?

Hi Russell,

My apologies; at some point i lost track of the discussion because
things seemed under control. 
Lets hear from Patrick - I have a lot of faith in him; i just happen to
know he is occupied elsewhere as we speak (which may explain his
silence). So please be a little patient with him. In the meantime please
dont be discouraged in continuing to contribute - sometimes this is how
things go.

You are right that if there is no generic solution from Patrick we
should not hold your patch. My understanding of Patrick's patch is it
covers for your case; i may have misread that given you and him are
still discussing the differences. 

Perhaps one approach is to push your patch in first and then when
Patrick is ready he can operate on that. Patrick, thoughts?

cheers,
jamal

