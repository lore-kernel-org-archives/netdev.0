From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: [PATCH] phylib: add mdio-gpio bus driver (v2)
Date: Tue, 28 Oct 2008 06:07:27 -0400
Message-ID: <8bd0f97a0810280307n7f14bd2bod11743db4e395e4@mail.gmail.com>
References: <20081027105318.21923.24436.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
	 <8bd0f97a0810270752p5fb6e560m6ddcf07df8f689f5@mail.gmail.com>
	 <4906CDAF.2070000@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org
To: "Paulius Zaleckas" <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:10988 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277AbYJ1KH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 06:07:28 -0400
In-Reply-To: <4906CDAF.2070000@teltonika.lt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 28, 2008 at 04:30, Paulius Zaleckas wrote:
> Mike Frysinger wrote:
>> On Mon, Oct 27, 2008 at 06:53, Paulius Zaleckas wrote:
>>> +       if (gpio_request(bitbang->mdc, "mdc"))
>>> +               goto out_free_bitbang;
>>> +
>>> +       if (gpio_request(bitbang->mdio, "mdio"))
>>> +               goto out_free_mdc;
>>
>> maybe include driver name and/or the platform id ?  if you have
>> multiple mdio-gpio's running at the same time, coordinating may get a
>> little messy ...
>
> Well... this is mostly for debugging only... I don't like the idea
> to add additional char[..] variable and use sprintf...
> IMO this would be just a bloat...

if realistically you'd only run one instance of this driver on a
platform, then it'll probably be fine

>>> +       new_bus->name = "GPIO Bitbanged MII",
>>
>> platform id here too ?
>
> If you take a look one line below you would see that bus ID is formed
> using platform id. Does this really need to be duplicated also in the
> name?

i guess if you can divine the differences from a populated /sys
directory, it should be ok as well
-mike
