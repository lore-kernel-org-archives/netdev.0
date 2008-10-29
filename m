From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: [PATCH] phylib: add mdio-gpio bus driver (v3)
Date: Wed, 29 Oct 2008 07:24:04 -0600
Message-ID: <fa686aa40810290624h272b9095hd56414c433ef832a@mail.gmail.com>
References: <20081028103537.28951.4804.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
	 <8bd0f97a0810280350j385a0239if7a33928f7bb11f1@mail.gmail.com>
	 <4906F817.4050306@teltonika.lt>
	 <fa686aa40810280726s338c739bl24ee53d3193292ba@mail.gmail.com>
	 <49082264.7060302@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Mike Frysinger" <vapier.adi@gmail.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org
To: "Paulius Zaleckas" <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from po-out-1718.google.com ([72.14.252.155]:60251 "EHLO
	po-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753764AbYJ2NYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 09:24:05 -0400
In-Reply-To: <49082264.7060302@teltonika.lt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2008 at 2:44 AM, Paulius Zaleckas
<paulius.zaleckas@teltonika.lt> wrote:
> Grant Likely wrote:
>> On Tue, Oct 28, 2008 at 5:31 AM, Paulius Zaleckas
>> <paulius.zaleckas@teltonika.lt> wrote:
>>> Mike Frysinger wrote:
>>>> On Tue, Oct 28, 2008 at 06:35, Paulius Zaleckas wrote:
>>>>> +config MDIO_GPIO
>>>>> +       tristate "Support for GPIO bitbanged MDIO buses"
>>>>>  config MDIO_OF_GPIO
>>>>>        tristate "Support for GPIO lib-based bitbanged MDIO buses"
>>>> seems to me these drivers have the same description ...
>>> Yes... but it is MDIO_OF_GPIO description that needs changing...
>>> Should I make patch for it?
>>
>> Wait a minute....  This is the same driver and it's just been
>> duplicated.  NAK.  Please don't do this.  Instead add a platform bus
>> binding to the existing driver.  Most of the code can be shared.
>
> It is very similar. If highly #ifdef'ed driver is OK then I can merge
> these driver to single one, but mdio-ofgpio driver name will have to
> change to mdio-gpio. OK?

Absolutely, change the name.  Also, I don't think you'll need as many
#ifdefs as you fear you do.  :-)  Mostly you'll need two #ifdef
sections; one for the of_platform binding and one for the platform
binding.  drivers/video/xilinxfb.c is a good example of how to do it.

g.

-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
