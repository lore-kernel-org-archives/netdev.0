From: Sam Leffler <sam@errno.com>
Subject: Re: Problem authenticating using WPA with bcm43xx-softmac
Date: Wed, 07 Jun 2006 09:01:42 -0700
Message-ID: <4486F866.9040901@errno.com>
References: <4485D66B.7080108@lwfinger.net>	 <1149682213.3999.14.camel@johannes>  <4486F513.5050906@lwfinger.net> <1149695470.3925.7.camel@johannes>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebb.errno.com ([69.12.149.25]:36618 "EHLO ebb.errno.com")
	by vger.kernel.org with ESMTP id S932280AbWFGQB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2006 12:01:56 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1149695470.3925.7.camel@johannes>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> On Wed, 2006-06-07 at 10:47 -0500, Larry Finger wrote:
> 
>> I have a little more information on what is happening. 
> 
> Great.
> 
>> In IEEE Std 802.11i-2004, which defines the 
>> WPA protocol, Figure 11a shows the sequence of exchanges needed to associate. Both bcm43xx-softmac 
>> and ndiswrapper go through the "Open System Authentication" process. 
> 
> Right, you always have to do that.
> 
>> Where they seem to diverge is 
>> in the STA's "Association Request (Security Parameters)" step. With ndiswrapper, the AP responds 
>> with a WPA EAPOL-Key message; whereas with softmac, the AP sends back the "invalid pairwise cipher 
>> message" and rejects the association.
> 
> Interesting. That's strange.
> 
>> Can anyone point to a reference that states what the content of the Association Request should be to 
>> get the AP to respond with the EAPOL-Key message? Unfortunately, I have no possibility of 
>> implementing a sniffer to see what a "correct" message contains.
> 
> Well, it should be shown in the 802.11i spec too.

Beware of the order of IE's in the management frames; some AP's are
touchy about this.

	Sam

