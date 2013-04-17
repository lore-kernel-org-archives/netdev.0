From: annie li <annie.li@oracle.com>
Subject: Re: GroupOrderList does not work for windows8?
Date: Wed, 17 Apr 2013 10:24:07 -0400
Message-ID: <516EB087.9020703@oracle.com>
References: <516EB051.3000405@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:34562 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966465Ab3DQOYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 10:24:11 -0400
Received: from acsinet22.oracle.com (acsinet22.oracle.com [141.146.126.238])
	by userp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r3HEO9IX000421
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 17 Apr 2013 14:24:10 GMT
Received: from aserz7022.oracle.com (aserz7022.oracle.com [141.146.126.231])
	by acsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r3HEO9lO004335
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 17 Apr 2013 14:24:09 GMT
Received: from abhmt112.oracle.com (abhmt112.oracle.com [141.146.116.64])
	by aserz7022.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r3HEO9wa004329
	for <netdev@vger.kernel.org>; Wed, 17 Apr 2013 14:24:09 GMT
In-Reply-To: <516EB051.3000405@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, I sent the wrong mail list, please ignore this.

Thanks
Annie
On 2013-4-17 10:23, annie li wrote:
> Hi
>
> I need to boot my bus driver before pci dirver, and I put my driver 
> tag in front of pci tag in Boot Bus Extender key of GroupOrderList, 
> just like suggested in http://support.microsoft.com/kb/115486.
>
> This way works well for window2012, but it never works for windows8. 
> It seems windows8 does not care about any change I did in 
> GroupOrderList. I enabled Verbose boot and the log shows pci is loaded 
> before my bus driver even though I put the tag of my bus driver in 
> front of tag of pci in GroupOrderList. Is it a known issue in 
> windows8? Anyone hit similar issue? Thanks.
>
> Thanks
> Annie
