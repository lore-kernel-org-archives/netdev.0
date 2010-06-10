From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 -next] niu: always include of_device.h
Date: Wed, 09 Jun 2010 17:29:25 -0700 (PDT)
Message-ID: <20100609.172925.183044544.davem@davemloft.net>
References: <20100609.110638.112605100.davem@davemloft.net>
	<20100609154409.bf024c0c.randy.dunlap@oracle.com>
	<AANLkTikuIgeSMC5_IzAQGEQRso4udBvBGPcioAiArWb5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: randy.dunlap@oracle.com, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: grant.likely@secretlab.ca
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikuIgeSMC5_IzAQGEQRso4udBvBGPcioAiArWb5@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Grant Likely <grant.likely@secretlab.ca>
Date: Wed, 9 Jun 2010 17:45:54 -0600

> On Wed, Jun 9, 2010 at 4:44 PM, Randy Dunlap <randy.dunlap@oracle.com=
> wrote:
>> From: Randy Dunlap <randy.dunlap@oracle.com>
>>
>> The niu driver uses struct of_device when built on any arch, not
>> only SPARC64, so always #include <linux/of_device.h>.
>>
>> drivers/net/niu.c:9700: warning: 'struct of_device' declared inside =
parameter list
>> drivers/net/niu.c:9700: warning: its scope is only this definition o=
r declaration, which is probably not what you want
>> drivers/net/niu.c:9716: warning: assignment from incompatible pointe=
r type
>>
>> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
>> Cc: =A0 =A0 Grant Likely <grant.likely@secretlab.ca>
>> Cc: =A0 =A0 Dave Miller <davem@davemloft.net>
>> ---
>> =A0drivers/net/niu.c | =A0 =A03 ---
>=20
> Looks okay to me (but I haven't build tested it yet).  The bulk of
> of_device.h is compiled out when CONFIG_OF_DEVICE is not selected.
>=20
> David, are you okay with me taking this via my tree as it depends on
> Randy's other patch?

Yep, that's totally fine with me:

Acked-by: David S. Miller <davem@davemloft.net>
