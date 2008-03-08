From: Patrick McHardy <kaber@trash.net>
Subject: Re: DoS by cat /proc/net/ip_conntrack ?
Date: Sat, 08 Mar 2008 16:18:30 +0100
Message-ID: <47D2AE46.1010406@trash.net>
References: <20080306134037.M70019@visp.net.lb> <Pine.LNX.4.64.0803061449220.23263@bizon.gios.gov.pl> <47D28601.4080106@gmail.com> <47D28786.80600@gmail.com> <20080308142254.M64724@visp.net.lb> <20080308144426.GB3378@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>,
	Krzysztof Oledzki <olel@ans.pl>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33799 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753265AbYCHPrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2008 10:47:14 -0500
In-Reply-To: <20080308144426.GB3378@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Sat, Mar 08, 2008 at 04:24:34PM +0200, Denys Fedoryshchenko wrote:
>   
>> For me personally, i think must be as a rule, that _READING_ must not hang 
>> whole system by consuming all resources (router becoming completely 
>> unreachable and blocking all traffic passing thru it). It can hang console, 
>> current program, but not crash router.
>>     
>
> IMHO you're right, and it's a bug. Only calling this DOS isn't probably
> very right if only root can do this, but maybe I'm wrong.
>   

Starting with current -git we don't take the conntrack
lock for /proc anymore, so it should behave better now.


