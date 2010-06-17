From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] iputils/ping_common.c: avoid gethostbyaddr during ping
 flood
Date: Thu, 17 Jun 2010 11:08:39 +0900
Message-ID: <4C1983A7.6050206@linux-ipv6.org>
References: <Pine.LNX.4.64.0802061401370.31285@nacho.alt.net> <Pine.LNX.4.64.1006170104000.26819@nacho.alt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Caputo <ccaputo-dated-1287104923.1c8263@alt.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:58472 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755892Ab0FQCJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 22:09:07 -0400
In-Reply-To: <Pine.LNX.4.64.1006170104000.26819@nacho.alt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Caputo wrote:
> On Wed, 6 Feb 2008, Chris Caputo wrote:
>> Unless a destination is specified by IP address, a ping flood results in a 
>> gethostbyaddr() for every echo reply.  Thus a DNS flood can accompany a 
>> ping flood.
> 
> Updated for iputils-s20100418...  Can someone review and work into next 
> release?

Applied, thanks.

--yoshfuji

