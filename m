From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NULL deref in bnx2 / crashes ? ( was: netconsole leads to
 stalled CPU task )
Date: Wed, 12 Sep 2012 15:05:35 +0200
Message-ID: <1347455135.13103.949.camel@edumazet-glaptop>
References: <CAF6-1L4wh0P-Wi-keN98wb-2V_avZYVE3ycf3tEe9SBpgK1dDQ@mail.gmail.com>
	 <1345634026.5158.1084.camel@edumazet-glaptop>
	 <CAF6-1L6zr5WJxo6FVk+2ya=EEs++u3x9iSrDxX-weBofLJuA1g@mail.gmail.com>
	 <1345640757.5158.1321.camel@edumazet-glaptop>
	 <CAF6-1L5hKU-VM0E5vCwExJ4kb8YB=ndotgfH7pbpxO6Q7+JHUQ@mail.gmail.com>
	 <k2q0ck$rpr$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:54631 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758043Ab2ILNFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 09:05:40 -0400
Received: by eaac11 with SMTP id c11so836717eaa.19
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2012 06:05:39 -0700 (PDT)
In-Reply-To: <k2q0ck$rpr$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-12 at 12:49 +0000, Cong Wang wrote:
> On Wed, 12 Sep 2012 at 11:53 GMT, Sylvain Munaut <s.munaut@whatever-company.com> wrote:
> > Hi Eric,
> >
> > AFAICT, the following patch was never merged but I just confirmed that
> > I do need it over 3.6-rc5 for things to work properly.
> >
> 
> Yes, indeed.
> 
> Eric, please resend your patch?
> 

Yes, but I have some worries of why it is needed.

Isnt it covering a bug elsewhere ?
