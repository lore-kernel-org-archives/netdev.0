From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.11 1/8] tg3: add 5705_plus flag
Date: Tue, 22 Mar 2005 15:52:27 -0500
Message-ID: <4240858B.5080209@pobox.com>
References: <B1508D50A0692F42B217C22C02D84972020F3E21@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Michael Chan <mchan@broadcom.com>, "David S. Miller" <davem@davemloft.net>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3E21@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> Add a 5705_plus flag to indicate the device is 5705, 5750, or future chips
> that all share the same basic architecture. This makes it easier to add
> support for future devices.
> 
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com

ACK, and two comments:

1) In general, I encourage changes like this, for both tg3 and other net 
drivers.  It is -much- better to define a feature flag, and test the 
feature flag in the source code, than to define a list of affected 
[chips | arches].  Changes like this

-       if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 ||
-           GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750) {
+       if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {

can be an example to others for future changes.


2) [administrivia]  Your patches are encoded as base64, which makes 
reviewing and applying your patches difficult.  You are violating clause 
#3, rules one and two:

	http://linux.yyz.us/patch-format.html

For sending patches, I highly recommend using a text file template, and 
/usr/sbin/sendmail (sendmail/postfix/exim mail servers provide this).  See

	http://lkml.org/lkml/2005/2/24/3

for more info.

If you don't want to bother with Unix, I -think- Mozilla Thunderbird for 
Windows will correctly attach patches in a way that is useable.

	http://www.mozilla.org/products/thunderbird/

Regards,

	Jeff
