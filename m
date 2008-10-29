From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: Re: [PATCH] phylib: add mdio-gpio bus driver (v3)
Date: Wed, 29 Oct 2008 10:44:20 +0200
Message-ID: <49082264.7060302@teltonika.lt>
References: <20081028103537.28951.4804.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>	 <8bd0f97a0810280350j385a0239if7a33928f7bb11f1@mail.gmail.com>	 <4906F817.4050306@teltonika.lt> <fa686aa40810280726s338c739bl24ee53d3193292ba@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Mike Frysinger <vapier.adi@gmail.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk,
	linux-embedded@vger.kernel.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linux-embedded-owner@vger.kernel.org>
In-Reply-To: <fa686aa40810280726s338c739bl24ee53d3193292ba@mail.gmail.com>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Grant Likely wrote:
> On Tue, Oct 28, 2008 at 5:31 AM, Paulius Zaleckas
> <paulius.zaleckas@teltonika.lt> wrote:
>> Mike Frysinger wrote:
>>> On Tue, Oct 28, 2008 at 06:35, Paulius Zaleckas wrote:
>>>> +config MDIO_GPIO
>>>> +       tristate "Support for GPIO bitbanged MDIO buses"
>>>>  config MDIO_OF_GPIO
>>>>        tristate "Support for GPIO lib-based bitbanged MDIO buses"
>>> seems to me these drivers have the same description ...
>> Yes... but it is MDIO_OF_GPIO description that needs changing...
>> Should I make patch for it?
> 
> Wait a minute....  This is the same driver and it's just been
> duplicated.  NAK.  Please don't do this.  Instead add a platform bus
> binding to the existing driver.  Most of the code can be shared.

It is very similar. If highly #ifdef'ed driver is OK then I can merge
these driver to single one, but mdio-ofgpio driver name will have to
change to mdio-gpio. OK?
