From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch] ethtool (was Re: Acer Aspire 1524WLMi and RealTek 8169
 - very slow)
Date: Thu, 27 Jan 2005 15:27:33 -0500
Message-ID: <41F94EB5.8090304@pobox.com>
References: <41A09541.5040405@phekda.gotadsl.co.uk> <20041121232850.GB22460@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Richard Dawe <rich@phekda.gotadsl.co.uk>, netdev@oss.sgi.com,
        davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041121232850.GB22460@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Richard Dawe <rich@phekda.gotadsl.co.uk> :
> 
>>diff -pur ethtool-2/ethtool.c ethtool-2.dev/ethtool.c
>>--- ethtool-2/ethtool.c	2004-07-02 16:28:48.000000000 +0100
>>+++ ethtool-2.dev/ethtool.c	2004-11-21 10:09:13.000000000 +0000
>>@@ -996,6 +996,7 @@ static struct {
>> } driver_list[] = {
>> 	{ "8139cp", realtek_dump_regs },
>> 	{ "8139too", realtek_dump_regs },
>>+	{ "r8169", realtek_dump_regs },
>> 	{ "de2104x", de2104x_dump_regs },
>> 	{ "e1000", e1000_dump_regs },
>> 	{ "natsemi", natsemi_dump_regs },
>>diff -pur ethtool-2/realtek.c ethtool-2.dev/realtek.c
>>--- ethtool-2/realtek.c	2004-04-09 19:44:55.000000000 +0100
>>+++ ethtool-2.dev/realtek.c	2004-11-21 11:31:29.015997736 +0000
>>@@ -43,7 +43,7 @@ static struct chip_info {
>> 	{ "RTL-8100B/8139D",	HW_REVID(1, 1, 1, 0, 1, 0, 1) },
>> 	{ "RTL-8139C+",		HW_REVID(1, 1, 1, 0, 1, 1, 0) },
>> 	{ "RTL-8101",		HW_REVID(1, 1, 1, 0, 1, 1, 1) },
>>-	{ "RTL-8169",		HW_REVID(0, 0, 0, 0, 0, 0, 0) },
>>+	{ "RTL-8169",		HW_REVID(0, 0, 1, 0, 0, 0, 0) },
> 
> 
> The initial value can be found in the datasheet and my Netgear adapter
> announces HW_REVID(0, 0, 0, 0, 1, 0, 0). Joy.
> 
> Dave, Jeff, any remark about the patch below ?
> 
> Index: ethtool.c
> ===================================================================
> RCS file: /cvsroot/gkernel/ethtool/ethtool.c,v
> retrieving revision 1.50
> diff -u -p -r1.50 ethtool.c
> --- ethtool.c	2 Jul 2004 15:35:09 -0000	1.50
> +++ ethtool.c	21 Nov 2004 23:22:54 -0000
> @@ -996,6 +996,7 @@ static struct {
>  } driver_list[] = {
>  	{ "8139cp", realtek_dump_regs },
>  	{ "8139too", realtek_dump_regs },
> +	{ "r8169", realtek_dump_regs },
>  	{ "de2104x", de2104x_dump_regs },
>  	{ "e1000", e1000_dump_regs },
>  	{ "natsemi", natsemi_dump_regs },


applied
