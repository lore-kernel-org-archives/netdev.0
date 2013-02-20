From: Chris Friesen <chris.friesen@genband.com>
Subject: why is it not allowed to add a new socket protocol family as an external
 module?
Date: Wed, 20 Feb 2013 10:56:13 -0600
Message-ID: <5125002D.9080008@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og121.obsmtp.com ([64.18.2.20]:50891 "EHLO
	exprod7og121.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777Ab3BTQ6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 11:58:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I was just wondering why the kernel doesn't allow a new network protocol 
family to be loaded as as a kernel module built outside the kernel 
source tree.

Most of the networking code would seem to allow this, but the check for
"if (ops->family >= NPROTO)" in sock_register() means that only protocol 
families defined in socket.h can be registered.

Was this intentional for ideological reasons, or has nobody wanted to be 
able to add arbitrary network protocols without patching the kernel and 
rebuilding?

Thanks,
Chris
