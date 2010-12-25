From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [net-next-2.6 04/15] e1000e: checkpatch error - open braces
Date: Sat, 25 Dec 2010 05:29:16 -0500
Message-ID: <4D15C77C.9030306@garzik.org>
References: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com> <1293257174-15498-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Bruce Allan <bruce.w.allan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:38569 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750708Ab0LYK3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Dec 2010 05:29:20 -0500
Received: by qyk12 with SMTP id 12so8347403qyk.19
        for <netdev@vger.kernel.org>; Sat, 25 Dec 2010 02:29:19 -0800 (PST)
In-Reply-To: <1293257174-15498-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/25/2010 01:06 AM, jeffrey.t.kirsher@intel.com wrote:
> From: Bruce Allan<bruce.w.allan@intel.com>
>
> ERROR: that open brace { should be on the previous line
>
> Signed-off-by: Bruce Allan<bruce.w.allan@intel.com>
> Tested-by: Emil Tantilov<emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/e1000e/es2lan.c  |    4 ++--
>   drivers/net/e1000e/ethtool.c |    4 ++--
>   drivers/net/e1000e/phy.c     |   22 +++++++++++-----------
>   3 files changed, 15 insertions(+), 15 deletions(-)
>
> diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
> index 79da646..b18c644 100644
> --- a/drivers/net/e1000e/es2lan.c
> +++ b/drivers/net/e1000e/es2lan.c
> @@ -100,8 +100,8 @@
>    * with a lower bound at "index" and the upper bound at
>    * "index + 5".
>    */
> -static const u16 e1000_gg82563_cable_length_table[] =
> -	 { 0, 60, 115, 150, 150, 60, 115, 150, 180, 180, 0xFF };
> +static const u16 e1000_gg82563_cable_length_table[] = {
> +	 0, 60, 115, 150, 150, 60, 115, 150, 180, 180, 0xFF };
>   #define GG82563_CABLE_LENGTH_TABLE_SIZE \
>   		ARRAY_SIZE(e1000_gg82563_cable_length_table)
>
> diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
> index 15c6330..affcacf 100644
> --- a/drivers/net/e1000e/ethtool.c
> +++ b/drivers/net/e1000e/ethtool.c
> @@ -753,8 +753,8 @@ static bool reg_pattern_test(struct e1000_adapter *adapter, u64 *data,
>   			     int reg, int offset, u32 mask, u32 write)
>   {
>   	u32 pat, val;
> -	static const u32 test[] =
> -		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
> +	static const u32 test[] = {
> +		0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
>   	for (pat = 0; pat<  ARRAY_SIZE(test); pat++) {
>   		E1000_WRITE_REG_ARRAY(&adapter->hw, reg, offset,
>   				      (test[pat]&  write));

Gah, that looks worse than the unpatched code.

I think this was an over-literal checkpatch interpretation.  If you look 
at e.g. drivers/net/tg3.c, you see that longer tables have the trailing 
braces on a separate line, where they should be.

IMO, the single-line cases should just be left as they are now in the 
source code.

	Jeff


