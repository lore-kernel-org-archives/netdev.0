From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH 01/16] dsa: slave: chip data is optional, don't
 dereference NULL
Date: Fri, 27 May 2016 14:24:26 -0700
Message-ID: <5748BB0A.8020905@gmail.com>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch>
 <1464312050-23023-2-git-send-email-andrew@lunn.ch>
 <87inxzz6ed.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34485 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756647AbcE0VY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 17:24:29 -0400
Received: by mail-pf0-f174.google.com with SMTP id 62so885344pfd.1
        for <netdev@vger.kernel.org>; Fri, 27 May 2016 14:24:29 -0700 (PDT)
In-Reply-To: <87inxzz6ed.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/27/2016 11:45 AM, Vivien Didelot wrote:
> Hi Andrew, Florian,
> 
> We are inconsistent on commit titles and messages. Some of them use
> "net: " prefix, some others don't, sometimes lower or upper case titles.
> 
> I'd suggest we stick with the "net: dsa: " prefix and lowercase titles.
> 
> When possible, let's try to respect the 50/72 Git rule.
> 
> So we'd have e.g.:
> 
>     net: dsa: add new bindings
>     net: dsa: mv88e6xxx: add support for foo
>     net: dsa: sf2: remove bar
>     ...
> 
> The networking documentation doesn't seem to have opinion on the "net: "
> prefix. We might drop it and keep only "dsa: " for core and drivers.
> 
> What do you think?

My preference goes for "net: dsa: <blah>", but at the same time, I don't
really care as long as I can git log the file.
-- 
Florian
