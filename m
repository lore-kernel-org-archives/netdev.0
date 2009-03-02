From: Patrick McHardy <kaber@trash.net>
Subject: Re: Vlan interface nuisance
Date: Mon, 02 Mar 2009 22:49:18 +0100
Message-ID: <49AC545E.3090708@trash.net>
References: <20090301204731.40ce346a@nehalam> <20090302172057.GA23247@csclub.uwaterloo.ca> <49AC2A9C.5090303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55156 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774AbZCBVtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 16:49:23 -0500
In-Reply-To: <49AC2A9C.5090303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Lennart Sorensen wrote, On 03/02/2009 06:20 PM:
> 
>> On Sun, Mar 01, 2009 at 08:47:31PM -0800, Stephen Hemminger wrote:
>>> Why is interface created through netlink named 'vlan0' and
>>> interface created through old vconfig called 'ethX.YY'.
>>> Seems like the interface should be consistent.
>> That does seem silly.
>>
>> ethX.YYYY told you which physical interface and which vlan number it was.
>>
>> vlan0 tells you nothing useful.
>  
> 
> Even if you have only one ethX?

The binding is displayed when listing interfaces. This hole
argument is silly, if you want a particular name, just specify
it. The current naming schemes are entirely based on information
that you have to specify anyways.
