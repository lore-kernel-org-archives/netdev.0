From: Scot Doyle <lkml@scotdoyle.com>
Subject: Re: Kernel panic when using bridge
Date: Fri, 08 Apr 2011 09:57:12 -0500
Message-ID: <4D9F2248.90300@scotdoyle.com>
References: <4D9E62D9.5010400@scotdoyle.com> <loom.20110408T153726-822@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pallai Roland <pallair@magex.hu>
To: Sebastian Nickel <Sebastian.Nickel@hetzner.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.scotdoyle.com ([74.207.249.244]:55635 "EHLO
	smtp.scotdoyle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757204Ab1DHO5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 10:57:14 -0400
In-Reply-To: <loom.20110408T153726-822@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2011 08:49 AM, Sebastian Nickel wrote:
> We have the same problems with kernel version 2.6.37.4 (unpatched). Almost same
> stacktrace.
>
> After some time there is a kernel panic.
>
> -br0 contains a realtek NIC (8169) and some vnet devices used with KVM.
>
> Any ideas would be great...

Perhaps the problem is isolated to the bridging code? Neither KVM guest 
nor associated tap device were running during my second reported panic.

Here's a similar stacktrace from a third person:
http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=620201
