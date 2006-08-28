From: "Benoit Boissinot" <bboissin@gmail.com>
Subject: Re: 2.6.18-rc4-mm[1,2,3] -- Network card not getting assigned an "eth" device name
Date: Mon, 28 Aug 2006 16:32:04 +0200
Message-ID: <40f323d00608280732y5e8e4dc1ib104564fe04b790a@mail.gmail.com>
References: <a44ae5cd0608270007gc6a919fx9e36562d8023635d@mail.gmail.com>
	 <20060827001943.c559d37d.akpm@osdl.org> <44F1C899.4020505@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@osdl.org>,
	"Miles Lane" <miles.lane@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.207]:176 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1750958AbWH1OcF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 10:32:05 -0400
Received: by nz-out-0102.google.com with SMTP id n1so1030512nzf
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2006 07:32:04 -0700 (PDT)
To: "Jeremy Fitzhardinge" <jeremy@goop.org>
In-Reply-To: <44F1C899.4020505@goop.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/27/06, Jeremy Fitzhardinge <jeremy@goop.org> wrote:
> Andrew Morton wrote:
> > Jeremy reported that a while back too.  I do not know what is causing it
> > and as far as I know no net developers have yet looked into it.
> >
>
> It went away with -rc4-mm[23] for me...
>
I just reproduced it with rc4-mm3, ipw2200 after coming out of
suspend. I'll apply the patch from David Miller and see if anything
shows out in the log.

regards,

Benoit
