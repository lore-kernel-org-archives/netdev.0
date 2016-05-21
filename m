From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: IPv6 extension header privileges
Date: Sat, 21 May 2016 13:46:56 -0400
Message-ID: <20160521174438.GA27990@oracle.com>
References: <CALx6S36x2+HBLSYVBi0+rQAgejbVvvFF7fr0P13cTspxpJQCLg@mail.gmail.com>
 <1e22f140-920e-0d1c-4a43-03780fb380a8@stressinduktion.org>
 <20160521015604.GD2452@oracle.com>
 <1463823275.2335717.614453105.5011B2EE@webmail.messagingengine.com>
 <CALx6S36V8Bv1R+rKWB7u=Y8371aT7JybDdkEErrRtw_bsHrMaA@mail.gmail.com>
 <6a889c73-efb1-7d4c-ba33-8b076378fcb7@stressinduktion.org>
 <CALx6S36scChuaS+uygAu4zk9gEz_qA=BSwX4f=kC_YXurTpMqw@mail.gmail.com>
 <f007389f-4ed1-2b67-69b5-28cd999264b9@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:48394 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496AbcEURrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2016 13:47:11 -0400
Content-Disposition: inline
In-Reply-To: <f007389f-4ed1-2b67-69b5-28cd999264b9@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert wrote:
> >>> If you don't mind I'll change this to make specific options are
> >>> privileged and not all hbh and destopt. There is talk in IETF about
> >>> reinventing IP extensibility within UDP since the kernel APIs don't
> >>> allow setting EH. I would like to avoid that :-)

Do you mean this
  http://www.ietf.org/mail-archive/web/spud/current/msg00365.html

Maybe I misunderstood that rather long thread, but the author of that
draft seems to be arguing for reinventing tcp congavoid and windowing 
on top of udp to bypass kernel? ;-)

Hannes Frederic Sowa wrote:
> >> A white list of certain registered IPv6 IANA-options for non-priv whould

Problem is that APIs are not IANA'ed. 
Even RFC 3542 is just Informationaal. 

And even the classic socket API's that come down from BSD are not 
ietf'ed or iana'ed.

Hannes Frederic Sowa wrote:
> Can you give some more details about the planned new options? I think we
> can also open the API up for all options where the fourth bit is set,
> which AFAIK denotes the experimental option space. And only have a
> blacklist for the fourth bit == 0 case. Otherwise this is something IETF
> people probably know more about what an impact this change could have.

I think it would be ok for some options to be privileged, others to not.
We certainly have precedent for that from the classic socket APIs..
and man pages etc can document any restrictions, as we do with other
ioctls/sockopts etc.

--Sowmini
