From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Problem authenticating using WPA with bcm43xx-softmac
Date: Wed, 07 Jun 2006 11:30:02 -0500
Message-ID: <4486FF0A.6010201@lwfinger.net>
References: <4485D66B.7080108@lwfinger.net> <1149682213.3999.14.camel@johannes> <4486F513.5050906@lwfinger.net> <1149695470.3925.7.camel@johannes> <4486F866.9040901@errno.com> <1149696400.3925.13.camel@johannes>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sam Leffler <sam@errno.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:36778 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S932310AbWFGQaF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jun 2006 12:30:05 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1149696400.3925.13.camel@johannes>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> On Wed, 2006-06-07 at 09:01 -0700, Sam Leffler wrote:
> 
>> Beware of the order of IE's in the management frames; some AP's are
>> touchy about this.
> 
> Uh oh. I have no idea where the ieee80211 layer sticks that one,
> probably at the end.

I can verify that. I'm currently building a new module with a printk to verify that it is being 
added. If it is, I'll try moving it to see if it helps.

Larry
