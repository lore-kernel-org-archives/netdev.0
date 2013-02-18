From: Mr Dash Four <mr.dash.four@googlemail.com>
Subject: Re: Fw: [Bug 53821] New: ip rules (policy routing) no longer applied
 consistency
Date: Mon, 18 Feb 2013 09:50:34 +0000
Message-ID: <5121F96A.6030101@googlemail.com>
References: <20130214082616.44ad070c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:35909 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500Ab3BRJun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 04:50:43 -0500
Received: by mail-wi0-f180.google.com with SMTP id hi8so3247056wib.1
        for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 01:50:41 -0800 (PST)
In-Reply-To: <20130214082616.44ad070c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Source IP based rules worked fine with kernels up to 3.6. Confusingly, _some_
> of them still work, but not all.
>
> Maybe something was broken by the removal of the route cache?
>   
I am also experiencing these issues. I too have a separate table based 
on source IP routing with higher priority than "main" and "default" and 
the routing seems to work whenever it feels like it (routing fine for 
some of the addresses, but not others), so I am going to revert to 3.6 
for the time being.
