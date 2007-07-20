From: patric <pakar@imperialnet.org>
Subject: Re: tg3 issues
Date: Fri, 20 Jul 2007 18:59:03 +0200
Message-ID: <46A0E9D7.7020904@imperialnet.org>
References: <469E78A2.80904@imperialnet.org> <366312910707190419se33ddd2o3870b5684e077276@mail.gmail.com> <20070719113755.GA1934@hmsreliant.homelinux.net> <469F6601.20800@imperialnet.org> <1184866465.10854.45.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailfront-6.lil-sth.crystone.net ([83.168.207.14]:43959 "HELO
	mailfront-6.lil-sth.se.crystone.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with SMTP id S1764148AbXGTQ7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 12:59:14 -0400
In-Reply-To: <1184866465.10854.45.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:

> On Thu, 2007-07-19 at 15:24 +0200, patric wrote:
>
>   
>> Just a hypothetical question. If the 2 network cards starts the 
>> autonegotiation would it be possible that they get into a loop where 
>> they are chasing each others state?  Maybe a fix could be to add a sleep 
>> of a random length that would enable them to catch up? Maybe you know if 
>> any of the fiber-cards so support running without flowcontrol too since 
>> the cards don't seem to be able to get a link with flowcontrol turned 
>> off at least in this setup.
>>
>>
>>     
>
> The old 5701 fiber NICs do not support autonegotiation in hardware so it
> is done "by hand" in the driver.  It is not the most robust way of doing
> autoneg and what you described is totally possible.  You might want to
> try disabling autoneg to see if it works any better.  There is only one
> possible speed in fiber and autoneg is really only used to negotiate
> flow control.  Some switch ports will not link up if the link partner
> does not do autoneg though.
>
> You have to use ethtool in initrd to turn off autoneg or just modify the
> driver to disable autoneg.
>
>
>   
Thanks... That's a confirmation on what i  suspected.. I think i'll dig 
into the code instead and try to figure out some way of making it work a 
bit better for my setup atleast...
I'll post a patch later if i get something working... Btw, do you have 
any timings on how long it takes for the cards to get a lock on the link?

Thanks for your input!

/Patric

