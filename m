From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Re: Telnet closing delay
Date: Thu, 3 Apr 2008 11:32:14 +0200
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD134F21C0@exch.facton.local>
References: <3C59DB883F7B0B4D8096010D45ACCD1323004D@exch.facton.local> <20070502091952.GA6060@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:32880 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758070AbYDCJjN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 05:39:13 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070502091952.GA6060@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Tue, May 01, 2007 at 10:48:11PM +0200, Beschorner Daniel
(Daniel.Beschorner@facton.com) wrote:
>> Since 2.6.21 I often got a 2 seconds delay when closing a telnet
session
>> to such a machine (even to localhost).
>> I was at least not aware of this with older versions, but maybe I'm
>> wrong?!?
>> Server with delay:
>> 
>> 0.000095 select(4, [0 3], [], [0], NULL) = 1 (in [3])
>> 0.001779 read(3, 0x8059de0, 8192)  = -1 EIO (Input/output error)

> Hmm, does not it supposed to stop doing such things on the closed
> socket and not enter 10000 select/read loop?
> Server behaves incorrectly in this scenario, why and how it can be
fixed
> is another questions better asked the author.

It must have been indeed triggered by a kernel change or bug, with
current 2.6.24.4 all works fine again.

Daniel
