From: Chris Friesen <cbf123@mail.usask.ca>
Subject: recommended way to support duplicate IP addresses on different VLANs?
Date: Mon, 11 Jul 2011 08:58:14 -0600
Message-ID: <4E1B0F86.2040508@mail.usask.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from idcmail-mo1so.shaw.ca ([24.71.223.10]:24578 "EHLO
	idcmail-mo1so.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756441Ab1GKO6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 10:58:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi all,

We've got a server that sits on multiple VLANs.  Each VLAN is segregated 
and doesn't know about the others.  The IP address ranges in each of the 
VLANs may overlap, and the server may be assigned the same IP address in 
multiple VLANs.

We've got a messy solution now involving unique internal addresses and 
NATing between those and the duplicate external addresses, but I'm 
wondering if there is a cleaner way to handle this.

It seems like network namespaces would work, but it would require 
multiple instances of our software which is a dealbreaker.

Is there any other way to deal with this scenario?

Thanks,
Chris
