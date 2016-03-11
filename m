From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 0/2] DT MDIO bus of fixed phys
Date: Fri, 11 Mar 2016 15:38:58 -0800
Message-ID: <56E35712.5080508@gmail.com>
References: <1457737726-23907-1-git-send-email-andrew@lunn.ch>
 <56E35432.2010300@gmail.com> <20160311233610.GB23969@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35271 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbcCKXkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 18:40:31 -0500
Received: by mail-pf0-f181.google.com with SMTP id n5so55641450pfn.2
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 15:40:31 -0800 (PST)
In-Reply-To: <20160311233610.GB23969@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/16 15:36, Andrew Lunn wrote:
> On Fri, Mar 11, 2016 at 03:26:42PM -0800, Florian Fainelli wrote:
>> On 11/03/16 15:08, Andrew Lunn wrote:
>>> Currently, supporting a fixed-phy in a MAC driver is a bit messy. It
>>> needs to be explicit supported, since a fixed phy is somewhat
>>> different from a normal phy.
>>>
>>> These two patches solve this by making fixed-phys appear as normal
>>> PHYs within device tree, allowing them to be referenced by a phandle.
>>> Any MAC driver that supports phy-handle can then automatically support
>>> a fixed-phy without any code change.
>>
>> Humm, if that's the problem we want to solve, we could introduce a
>> helper function which tries to locate the phy using a 'phy-handle'
>> property
> 
> I don't follow you. Where do you get a phandle from to use with
> phy-handle?

>From the caller of the function: the consumer of that phy-handle and/or
fixed-link property which is either an Ethernet MAC driver or a DSA's
switch port node.
-- 
Florian
