From: Pierre Louis Aublin <pierre-louis.aublin@inria.fr>
Subject: loopback interface - why checksum on header?
Date: Sat, 23 Jul 2011 18:30:18 +0200
Message-ID: <4E2AF71A.6080703@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4-relais-sop.national.inria.fr ([192.134.164.105]:61920
	"EHLO mail4-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752919Ab1GWQaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2011 12:30:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everybody

I am wondering why the checksum of packets sent through the loopback 
interface is computed on the header only.
If I understand correctly, it is assumed that a message cannot be 
corrupted in RAM, thus there is no need to verify the integrity of the 
whole message.
However, in that case, there is also no need to compute it on the header.
Consequently, why is it not the case?

Thank you in advance
Pierre Louis Aublin
