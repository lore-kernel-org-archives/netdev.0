From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.10] tg3: add tg3_set_eeprom
Date: Thu, 20 Jan 2005 16:59:23 -0800
Message-ID: <20050120165923.39f736f4.davem@davemloft.net>
References: <B1508D50A0692F42B217C22C02D84972020F3D32@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3D32@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 20 Jan 2005 16:00:38 -0800
"Michael Chan" <mchan@broadcom.com> wrote:

> Detailed changes:

Thanks a lot Michael, patch applied.

Another thing that makes patches like this one easier to review
is to split them up as much as is reasonable possible.  As a specific
suggestion, for this patch we might have first done a change which
added all of the NVRAM chip IDs and probed for them, the next change
might be the change from tw32_f() to tw32() for the chip register
accesses, the next change would make use of the NVRAM chip ID type
and finally we'd have the change that implemented tg3_set_eeprom().

That's how you likely, at least logically, implemented this patch
in a step by step fashion.  If you really do split the change up into
pieces like that, the individual patches are much easier to verify
and review than the whole thing put together and submitted all at
once.

Thanks again.
