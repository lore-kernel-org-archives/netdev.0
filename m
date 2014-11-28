From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH][v2] mdio-mux-gpio: Use GPIO descriptor interface and new
 gpiod_set_array function
Date: Fri, 28 Nov 2014 14:49:20 +0100
Message-ID: <CACRpkdaZZFL+1FC8cANAqkMZu8amkPyC5BDaxTF2Fnj2zpqn1Q@mail.gmail.com>
References: <2814617.OrXEO01vgP@pcimr>
	<547487A4.6050203@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rojhalat Ibrahim <imr@rtschenk.de>,
	"linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexandre Courbot <acourbot@nvidia.com>,
	David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	David Daney <david.daney@cavium.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:34072 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976AbaK1NtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 08:49:21 -0500
Received: by mail-ig0-f175.google.com with SMTP id h15so9949247igd.2
        for <netdev@vger.kernel.org>; Fri, 28 Nov 2014 05:49:20 -0800 (PST)
In-Reply-To: <547487A4.6050203@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 2:44 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> On 11/25/2014 12:31 PM, Rojhalat Ibrahim wrote:
> [...]
>>
>>   static int mdio_mux_gpio_remove(struct platform_device *pdev)
>>   {
>> +       unsigned int n;
>>         struct mdio_mux_gpio_state *s = dev_get_platdata(&pdev->dev);
>>         mdio_mux_uninit(s->mux_handle);
>> +       for (n = 0; n < s->num_gpios; n++) {
>> +               gpiod_put(s->gpio[n]);
>> +       }
>
>
>    {} not needed; scripts/checkpatch.pl should have complained...

Yep it complains so I fixed it up when applying the patch.

Yours,
Linus Walleij
