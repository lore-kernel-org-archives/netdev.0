From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.10] tg3: add tg3_set_eeprom
Date: Thu, 20 Jan 2005 15:05:19 -0800
Message-ID: <20050120150519.08ef54fa.davem@davemloft.net>
References: <B1508D50A0692F42B217C22C02D84972020F3D2E@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3D2E@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 20 Jan 2005 14:52:14 -0800
"Michael Chan" <mchan@broadcom.com> wrote:

> Add tg3_set_eeprom routine to support configuration changes (e.g. ASF
> config).
> 
> Made changes to other nvram related routines.

Why were the NVRAM_ACCESS writes change to non-flushing register
writes?  Otherwise I think your patch is fine.

Maybe it would be nice if you provided a detailed changelog
of sorts, because other's might have similar questions like I
did about why the tw32_f() --> tw32() changes were made.
