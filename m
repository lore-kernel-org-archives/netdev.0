From: Shan Wei <shanwei88@gmail.com>
Subject: Re: [PATCH 2/2] ss: implement -M option to get all memory information
Date: Fri, 27 Apr 2012 10:04:17 +0800
Message-ID: <4F99FEA1.2000700@gmail.com>
References: <4F97A48F.4010109@gmail.com> <20120425104128.4d6e13e1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, NetDev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f51.google.com ([209.85.210.51]:41920 "EHLO
	mail-pz0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757840Ab2D0CDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 22:03:30 -0400
Received: by dadz8 with SMTP id z8so303809dad.10
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2012 19:03:29 -0700 (PDT)
In-Reply-To: <20120425104128.4d6e13e1@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger said, at 2012/4/26 1:41:

>>  "   -m, --memory        show socket memory usage\n"
>> +"   -M, --skmem         show socket memory information.\n"
>> +"                       this option which will replace -m, is valid since Linux 3.3.\n"
> 
> Please don't add reference to kernel version.
> Why does this need to be a new option? Maybe just do the right thing
> if present in the netlink response?


Actually, I'm ok for your suggestion that using a existing option(-m) to
export all memory information. But with a new option is better for us.

Maybe some people use latest iproute source with under kernel 3.3.0, some don't.
-m option will take different user experience, specially for UDP socket.
Currently -m option has no effect on UDP socket which i will submit another patch
to export memory information for. new option, fresh experience.

(Exporting out memory information will help us to analysis dropped packets 
which recorded in RcvbufErrors and SndbufErrors.)
 

 
