From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: IPsec with aes-cbc and geode-aes driver completely freezes 2.6.20.1
Date: Thu, 15 Mar 2007 17:15:06 +0300
Message-ID: <20070315141506.GA8597@2ka.mipt.ru>
References: <20070315134533.21402.qmail@web51408.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, info-linux@geode.amd.com
To: Joerg Pommnitz <pommnitz@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:42339 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422710AbXCOOPL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 10:15:11 -0400
Content-Disposition: inline
In-Reply-To: <20070315134533.21402.qmail@web51408.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 15, 2007 at 06:45:33AM -0700, Joerg Pommnitz (pommnitz@yahoo.com) wrote:
> Hello all,
> the subject line basically says it all. I was trying to offload IPsec encryption to the hardware encryption engine on my Geode LX800. The exact same setkey command works fine with software aes.
> 
> In case it matters: this is with a MSEP800/A board from DIGITAL-LOGIC AG (see http://www.digitallogic.com/english/products/catalog07/epic_detail.asp?id=MSEP800_L).
> 
> Did anybody ever succeed with Geode hardware accelerated IPsec? Did you have to do anything special?

Please enable as much kernel debugging options as possible and rerun the
test - our mind readers are currently on vacations, so we fail to
find a problem.

If there will not be any signs of the problem, try to add several printk
into main geode crypto functions (there are not that many of them) or
press various sysrq combinations to determine where stall happens.

> -- 
> 
> Regards
> 
>        Joerg

-- 
	Evgeniy Polyakov
