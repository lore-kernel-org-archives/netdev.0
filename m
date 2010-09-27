From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP: orphans broken by RFC 2525 #2.17
Date: Mon, 27 Sep 2010 13:08:13 -0700
Message-ID: <4CA0F9AD.5050302@hp.com>
References: <20100926131717.GA13046@1wt.eu>	<20100927080222.GA31309@gondor.apana.org.au> <20100927200018.GY12373@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.hengli.com.au>, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:39144 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932619Ab0I0UIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 16:08:17 -0400
In-Reply-To: <20100927200018.GY12373@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Willy Tarreau wrote:
> Hi Herbert,
> 
> On Mon, Sep 27, 2010 at 04:02:22PM +0800, Herbert Xu wrote:
> 
>>Willy Tarreau <w@1wt.eu> wrote:
>>
>>>Looking more closely, I noticed that in traces showing the issue,
>>>the client was sending an additional CRLF after the data in a
>>>separate packet (permitted eventhough not recommended).
>>
>>Where is this permitted? RFC2616 says:
>>
>>	Certain buggy HTTP/1.0 client implementations generate
>>	extra CRLF's after a POST request. To restate what is
>>	explicitly forbidden by the BNF, an HTTP/1.1 client MUST
>>	NOT preface or follow a request with an extra CRLF. 
> 
> 
> And the paragraph just before says :
> 
>    In the interest of robustness, servers SHOULD ignore any empty
>    line(s) received where a Request-Line is expected. In other words, if
>    the server is reading the protocol stream at the beginning of a
>    message and receives a CRLF first, it should ignore the CRLF.

It is the HTTP server code being addressed there, not the underlying TCP stack 
is it not?


rick jones
