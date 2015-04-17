From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] dsa: mv88e6xxx: Fix error handling in mv88e6xxx_set_port_state
Date: Thu, 16 Apr 2015 19:05:11 -0700
Message-ID: <55306A57.4060701@roeck-us.net>
References: <1429161162-2028-1-git-send-email-linux@roeck-us.net>	<552FBD4C.4070405@roeck-us.net> <CAMuHMdVEbXGLR_svG9tHVMSvEOfajNX6GxAo113n2TfvGSRcwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:33293 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbbDQCFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 22:05:16 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1Yivee-002rOo-AQ
	for netdev@vger.kernel.org; Fri, 17 Apr 2015 02:05:16 +0000
In-Reply-To: <CAMuHMdVEbXGLR_svG9tHVMSvEOfajNX6GxAo113n2TfvGSRcwA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/16/2015 11:51 AM, Geert Uytterhoeven wrote:
> On Thu, Apr 16, 2015 at 3:46 PM, Guenter Roeck <linux@roeck-us.net> w=
rote:
>> On 04/15/2015 10:12 PM, Guenter Roeck wrote:
>>>
>>> Return correct error code if _mv88e6xxx_reg_read returns an error.
>>>
>>> Fixes: facd95b2e0ec0 ("net: dsa: mv88e6xxx: Add Hardware bridging
>>> support")
>>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
>>
>>
>> I should have given proper credit.
>>
>> Reported-by: kbuild test robot <fengguang.wu@intel.com>
>>
>> For the curious, neither W=3D1, W=3D2, C-1, C=3D2, nor sparse report=
 this problem,
>> at least not with gcc 4.9.1.
>
> Good old gcc 4.1.2 (which I still use for m68k builds, and won't reti=
re anytime
> soon as it finds real bugs in every new kernel release) says:
>
>      drivers/net/dsa/mv88e6xxx.c: In function =E2=80=98mv88e6xxx_set_=
port_state=E2=80=99:
>      drivers/net/dsa/mv88e6xxx.c:905: warning: =E2=80=98ret=E2=80=99 =
may be used
> uninitialized in this function
>
> Even after your patch, as it missed one case (patch sent).
>

Grumble. So much for trusting tools :-(

Thanks for fixing this!

Guenter
