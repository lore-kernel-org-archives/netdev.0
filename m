From: Pavel Emelyanov <xemul@virtuozzo.com>
Subject: Re: [CRIU] TCP_REPAIR MSS issue
Date: Tue, 14 Jun 2016 14:28:11 +0300
Message-ID: <575FEA4B.2000603@virtuozzo.com>
References: <C6D17923-7965-4483-8604-C654BFF1E0FF@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"criu@openvz.org" <criu@openvz.org>,
	Andrey Vagin <avagin@virtuozzo.com>
To: "Eggert, Lars" <lars@netapp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0145.outbound.protection.outlook.com ([157.55.234.145]:18724
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751035AbcFNL4h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 07:56:37 -0400
In-Reply-To: <C6D17923-7965-4483-8604-C654BFF1E0FF@netapp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/10/2016 02:22 PM, Eggert, Lars wrote:
> Hi,
> 
> I see an issue with TCP_REPAIR on kernel 4.6.0, where a migrated connection is only sending minimum-sized
> segments (~500 bytes), although the interfaces and path support Ethernet-sized MTUs. A connection that 
> doesn't use TCP_REPAIR over the same path uses full-sized segments.
> 
> Know issue? Any workaround?

Andrey (in Cc) has played with TCP_REPAIR recently, I guess he can know something.

> Thanks,
> Lars
> 
> 
> 
> 
> _______________________________________________
> CRIU mailing list
> CRIU@openvz.org
> https://lists.openvz.org/mailman/listinfo/criu
> 
