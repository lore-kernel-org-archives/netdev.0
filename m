From: Stephan Gatzka <stephan.gatzka@gmail.com>
Subject: IPv6 over Firewire
Date: Fri, 21 Dec 2012 18:03:21 +0100
Message-ID: <50D49659.1000101@gmail.com>
Reply-To: stephan.gatzka@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44718 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121Ab2LURDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 12:03:25 -0500
Received: by mail-bk0-f46.google.com with SMTP id q16so2532179bkw.5
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 09:03:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I'm currently implementing IPv6 over firewire.

To make the address mapping to the firewire link layer RFC3146 mandates 
to use neighbor discovery with a certain format of the source/target 
link-layer address option.

While it is not too complicated to build that up, I'm wondering how I 
can reserve enough memory in the corresponding skb.

One possibility is to introduce some option padding in 
ndisc_addr_option_pad() but I think that's somehow weird.

The second option I see is to set needed_tailroom in struct netdevice 
for firewire net devices. That's the way I would go for.

Because I'm not really familiar with the whole network infrastructure in 
Linux, a confirmation for the way to go would be nice.

Regards,

Stephan
