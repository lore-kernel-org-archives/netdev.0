From: "Charley (Hao Chuan) Chu" <charley.chu@broadcom.com>
Subject: RE: Kernel Oops in __inet_twsk_kill()
Date: Wed, 5 Nov 2014 20:35:15 +0000
Message-ID: <FB8A4655DFD2B34DB16AE06DDDD6C0E231A72A4B@SJEXCHMB12.corp.ad.broadcom.com>
References: <545A49B4.7090107@iogearbox.net>
	<CAHA+R7PAdVS=TBd8ZDAW3wdadjNEVjiyemrs54wNp8fdtCMvZQ@mail.gmail.com>
	<FB8A4655DFD2B34DB16AE06DDDD6C0E231A71CE3@SJEXCHMB12.corp.ad.broadcom.com>
 <20141105.143929.861274469992898400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "cwang@twopensource.com" <cwang@twopensource.com>,
	"borkmann@iogearbox.net" <borkmann@iogearbox.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:18087 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867AbaKEUfO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 15:35:14 -0500
In-Reply-To: <20141105.143929.861274469992898400.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Sorry, it is my mistake forgot to mention we have third party patch applied.

Thanks,
Charley

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Wednesday, November 05, 2014 11:39 AM
To: Charley (Hao Chuan) Chu
Cc: cwang@twopensource.com; borkmann@iogearbox.net; netdev@vger.kernel.org
Subject: Re: Kernel Oops in __inet_twsk_kill()

From: "Charley (Hao Chuan) Chu" <charley.chu@broadcom.com>
Date: Wed, 5 Nov 2014 19:16:09 +0000

> The problem has been fixed. It is introduced by a third party patch,
> which decreases the refcnt of timewait socket.

This is something that really drives me nuts, seriously?

Never report problems to us when you have such patches applied.

It is an even larger crime to not mention this at all from the
beginning, because we might start to investigate and waste our
precious time doing so.
