From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: e1000 TX hang problems
Date: Mon, 1 May 2006 15:15:36 -0700
Message-ID: <4807377b0605011515r706b2426nf085b1f29eb0927b@mail.gmail.com>
References: <1146211982.10106.7.camel@tux.co.za>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xproxy.gmail.com ([66.249.82.207]:53920 "EHLO xproxy.gmail.com")
	by vger.kernel.org with ESMTP id S932299AbWEAWPg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 18:15:36 -0400
Received: by xproxy.gmail.com with SMTP id t10so1838183wxc
        for <netdev@vger.kernel.org>; Mon, 01 May 2006 15:15:36 -0700 (PDT)
To: gerhard.dejager@ss-online.co.za
In-Reply-To: <1146211982.10106.7.camel@tux.co.za>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/28/06, Gerhard de Jeger <gerhard.dejager@ss-online.co.za> wrote:
> I'm also experiencing TX hang problems with the e1000 driver.
>
> I was using the 6.0.60-k2 version previously which shipped with the
> 2.6.14.2 kernel.
>
> I had no problems with this driver, but after my issues with the 7.0.33
> driver I tried to go back to the 6.0.60-k driver. Now when I load the
> module, there is an error saying that the EEPROM is corrupt - so I
> cannot use the old driver which used to work.

so what kernel are you using now?  what kind of hardware do you have?
we need a decent bug report in order to make some progress.

> Why is it that I now get the EEPROM error with the older driver?

did you change the kernel?

> Any ideas on how to fix the problem (with either the old driver or the
> new one)?

it sounds like you may have had a hardware failure?  Or maybe a kernel
problem.  Did you go back to 2.6.14.2 and try it?

It is highly unusual for the driver to be able to change the eeprom
through regular usage.

Please reply with more specifics
