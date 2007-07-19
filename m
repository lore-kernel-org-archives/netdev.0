From: Gabriel C <nix.or.die@googlemail.com>
Subject: Re: net/ipv4/inetpeer.c stack warnings
Date: Thu, 19 Jul 2007 15:10:40 +0200
Message-ID: <469F62D0.4030003@googlemail.com>
References: <469F5941.7090900@googlemail.com> <469F5DBB.3080106@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fonzie.hosting9000.com ([85.214.50.12]:54352 "EHLO
	fonzie.hosting9000.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758539AbXGSNMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 09:12:08 -0400
In-Reply-To: <469F5DBB.3080106@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Gabriel C wrote:
>   
>> Hello ,
>>
>> I noticed on current git this warning in net/ipv4/inetpeer.c
>>     
>
> Yeah, I have no idea why the gcc people thought that this was
> something worth warning about. Especially since explicitly
> checking for != NULL silences the warning again.
>
>
>   

Thx , the patch fixes that for me.

Gabriel
