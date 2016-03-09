From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [PATCH 0/3] net: macb: Fix coding style issues
Date: Wed, 9 Mar 2016 17:29:39 +0100
Message-ID: <56E04F73.6030504@xilinx.com>
References: <1457367460-9123-1-git-send-email-moritz.fischer@ettus.com>
 <56DDB6CA.8000100@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Moritz Fischer <moritz.fischer@ettus.com>,
	Michal Simek <michal.simek@xilinx.com>,
	"Cyrille Pitchen" <cyrille.pitchen@atmel.com>,
	David Miller <davem@davemloft.net>,
	Punnaiah Choudary Kalluri <punnaia@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56DDB6CA.8000100@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7.3.2016 18:13, Nicolas Ferre wrote:
> Le 07/03/2016 17:17, Moritz Fischer a =E9crit :
>> Hi Nicolas,
>>
>> this series deals with most of the checkpatch warnings
>> generated for macb. There are two BUG_ON()'s that I didn't touch, ye=
t,
>> that were suggested by checkpatch, that I can address in a follow up
>> commit if needed.
>> Let me know if you want me to split the fixes differently or squash
>> them into one commit.
>=20
> Hi,
>=20
> I'm not usually fond of this type of patches, but I must admit that t=
his
> series corrects some style issues.
>=20
> So, I would like more feedback from Michal and Cyrille as these chang=
es
> may delay some of the not-merged-yet features or more important
> work-in-progress on their side.
>=20
> On the other hand, if we all think it's a calm period for this macb
> driver, we may find interesting to merge some "cleanup and style"
> enhancements.

Not a problem with merging cleanups in general. We have several out of
tree patches but doesn't make sense to to wait.
I wasn't in cc for the series but I don't like this change to be the
part of cleanup series.

	mac =3D of_get_mac_address(np);
 	if (mac)
-		memcpy(bp->dev->dev_addr, mac, ETH_ALEN);
+		ether_addr_copy(bp->dev->dev_addr, mac);
 	else

Also extending scope of variables is not the right way to go. Especiall=
y
when some automation tools are reporting that you should reduce scope o=
f
use for them. Wolfram is checking it for example.

Thanks,
Michal
