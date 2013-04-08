From: David R <david@unsolicited.net>
Subject: Re: AMD Vi error and lost networking with r8169
Date: Mon, 08 Apr 2013 07:14:54 +0100
Message-ID: <20130408071454.452245lnz2ydnxwe@vinovium.com>
References: <51616695.7080305@unsolicited.net>
 <20130407215303.GA28778@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.unsolicited.net ([173.255.193.191]:35540 "EHLO
	mx1.unsolicited.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934870Ab3DHGO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 02:14:59 -0400
In-Reply-To: <20130407215303.GA28778@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sure. Will apply this evening. It may take several days before I can  
report back due to the intermittent nature of the thing.

Thanks
David


Quoting Francois Romieu <romieu@fr.zoreil.com>:

> David R <david@unsolicited.net> :
>> I'm been seeing some problems with my new ish AMD motherboard/processor
>> combo and networking (r8169). I see the following page fault :-
>>
>> Apr  7 12:25:14 david kernel: [156421.436545] AMD-Vi: Event logged
>> [IO_PAGE_FAULT device=02:00.0 domain=0x0015 address=0x0000000000003000
>> flags=0x0050]
>
> Can you give the hack below a try ?
>
> diff --git a/drivers/net/ethernet/realtek/r8169.c  
> b/drivers/net/ethernet/realtek/r8169.c
> index 28fb50a..ed8625d 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -4125,6 +4125,8 @@ static void rtl_init_rxcfg(struct rtl8169_private *tp)
>  	case RTL_GIGA_MAC_VER_23:
>  	case RTL_GIGA_MAC_VER_24:
>  	case RTL_GIGA_MAC_VER_34:
> +	case RTL_GIGA_MAC_VER_35:
> +	case RTL_GIGA_MAC_VER_36:
>  		RTL_W32(RxConfig, RX128_INT_EN | RX_MULTI_EN | RX_DMA_BURST);
>  		break;
>  	default:
>
