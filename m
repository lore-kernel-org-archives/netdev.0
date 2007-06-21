From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: [RFC NET 00/02]: Secondary unicast address support
Date: Thu, 21 Jun 2007 14:11:49 -0700
Message-ID: <1EF1E44200D82B47BD5BA61171E8CE9D0439BB96@NT-IRVA-0750.brcm.ad.broadcom.com>
References: <20070621.121305.109899848.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3851 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755550AbXFUVL5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 17:11:57 -0400
Received: from mail-irva-8.broadcom.com (mail-irva-8 [10.10.64.221]) by
 mail-irva-10.broadcom.com (Postfix) with ESMTP id 3AF072AE for
 <netdev@vger.kernel.org>; Thu, 21 Jun 2007 14:11:50 -0700 (PDT)
Received: from NT-IRVA-0750.brcm.ad.broadcom.com (
 nt-irva-0750.brcm.ad.broadcom.com [10.8.194.64]) by
 mail-irva-12.broadcom.com (Postfix) with ESMTP id 082B469CA5 for
 <netdev@vger.kernel.org>; Thu, 21 Jun 2007 14:11:50 -0700 (PDT)
Content-class: urn:content-classes:message
In-Reply-To: <20070621.121305.109899848.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev-owner@vger.kernel.org wrote:
> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Thu, 21 Jun 2007 13:08:12 -0600
> 
>> However this just seems to allow a card to decode multiple mac
>> addresses which in some oddball load balancing configurations may
>> actually be useful, but it seems fairly limited.
>> 
>> Do you have a specific use case you envision for this multiple mac
>> functionality?
> 
> Virtualization.
> 
> If you can't tell the ethernet card that more than 1 MAC
> address are for it, you have to turn the thing into promiscuous mode.
> 
> Networking on virtualization is typically done by giving each
> guest a unique MAC address, the guests have a virtual network
> device that connects to the control node (or dom0 in Xen
> parlace) and/or other guests.
> 
> The control node has a switch that routes the packets from
> the guests either to other guests or out the real ethernet interface.
> 
> Each guest gets a unique MAC so that the switch can know
> which guest an incoming packet is for.

The same software switch could also throw away the excess
frames that promiscuous mode would have admitted. Unless
the misdirected frames were common it would not seem to 
be a major CPU burden.

Keep in mind that the only MAC addresses that would have
been transmitted are the ones that the input filter would
have listed. 


