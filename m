From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Fri, 20 Nov 2015 08:47:50 +0900
Message-ID: <CAKD1Yr1u9gWefNDYT6fQxGtbJ_v+RZ5afc1xQhrRW0rPDFQ05Q@mail.gmail.com>
References: <1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
 <1447952902.2049284.444501617.7C422D07@webmail.messagingengine.com>
 <CALx6S379hXL=QEBF-HmOvPr3K55tS87HV=wKOySro1A0ogmWcQ@mail.gmail.com>
 <20151119.130923.186891318318651425.davem@davemloft.net> <1447957669.2293924.444570833.0E151DD6@webmail.messagingengine.com>
 <1447974142.3068929.444817369.068F6E50@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:33236 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163AbbKSXsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 18:48:11 -0500
Received: by ykdv3 with SMTP id v3so135142678ykd.0
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 15:48:10 -0800 (PST)
In-Reply-To: <1447974142.3068929.444817369.068F6E50@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2015 at 8:02 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Thu, Nov 19, 2015, at 19:27, Hannes Frederic Sowa wrote:
>> I will research the semantics behind tcpdrop:
>> <http://www.freebsd.org/cgi/man.cgi?query=tcpdrop&apropos=0&sektion=0&manpath=FreeBSD+10.2-RELEASE&arch=default&format=html>
>
> Fyi, my research shows that it just sends RST and discards complete
> socket state.

That makes sense. It is what RFC 793 calls ABORT:

http://tools.ietf.org/html/rfc793#page-50
