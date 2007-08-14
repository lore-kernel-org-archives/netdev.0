From: Wolfgang Nothdurft <Wolfgang.Nothdurft@linogate.de>
Subject: Re: 2.4.35-pre1: new e1000 driver breaks old hardware
Date: Tue, 14 Aug 2007 10:53:00 +0200
Message-ID: <46C16D6C.1030704@linogate.de>
References: <46723F39.1000808@linogate.de> <4672B5FD.7070304@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linogate.de ([213.179.141.2]:1213 "EHLO mail.linogate.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754324AbXHNJZv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 05:25:51 -0400
In-Reply-To: <4672B5FD.7070304@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Wolfgang Nothdurft wrote:
>> Hi,
>>
>> with the new e1000 driver version 7.3.20 the onboard gigabit nic 82547EI
>> (8086:1019) doesn't work correctly.
>> After transferring about 100 megabytes over a gigabit link the transfer
>> stopped and I have to reinit the link either by doing a ifconfig down/up
>> or unplugging the network cable.
>> The RxIntDelay is set to 0 like described in the docu. Playing with this
>> Parameter only increases the amount of traffic to be send and the error
>> occurs later.
> 
> have you tried (the default) 8000 ? Do you get the same problem when you 
> run 2.6.21 with 7.5.5.1 or 7.3.20 ?
> 
>> This happens also with the 7.4.35 and 7.5.5 driver from the intel side.
>> The driver 5.7.6 from kernel 2.4.33.3 and the 6.1.16 from intel works
>> very well on this hardware.
>> Also other gigabit nics we use didn't have this problem.
>> Is this issue already known?
> 
> this is the first time I have heard this issue.
> 
>> Is there any solution yet?
> 
> I'm not that good :)
> 
> Can you file a bugreport on e1000.sf.net and attach the usual (ethtool 
> -e, dmesg, ifconfig -a, lspci -vv) debugging output and problem 
> description for us? I'll try to see if I can have our labs setup a repro 
> case, which might be hard given the adapter type, but we will do our best.
> 
> Auke
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Any news about this issue?
The bug report is 
http://sourceforge.net/tracker/index.php?func=detail&aid=1739537&group_id=42302&atid=447449

Kind Regards
Wolfgang

-- 
Wolfgang Nothdurft                 Wolfgang.Nothdurft@linogate.de
Linogate Internet Technologies     fon: +49 (0)821 - 25 96 - 0
