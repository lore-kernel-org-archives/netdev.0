From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [v3] skbuff: Do not scrub skb mark within the same name space
Date: Thu, 16 Apr 2015 09:35:31 +0200
Message-ID: <552F6643.4090206@6wind.com>
References: <20150415100107.GA3655@gondor.apana.org.au> <552E3B7A.2040701@6wind.com> <20150415102229.GA3917@gondor.apana.org.au> <20150415135739.GA5534@gondor.apana.org.au> <552E86A6.9000101@6wind.com> <20150416010326.GA10864@gondor.apana.org.au> <alpine.LRH.2.11.1504161700130.23392@namei.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	linux-security-module@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: James Morris <jmorris@namei.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:36424 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664AbbDPHfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 03:35:34 -0400
Received: by wizk4 with SMTP id k4so183477212wiz.1
        for <netdev@vger.kernel.org>; Thu, 16 Apr 2015 00:35:33 -0700 (PDT)
In-Reply-To: <alpine.LRH.2.11.1504161700130.23392@namei.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/04/2015 09:02, James Morris a =E9crit :
> On Thu, 16 Apr 2015, Herbert Xu wrote:
[snip]
>> PS I used the wrong email for James the first time around.  So
>> let me repeat the question here.  Should secmark be preserved
>> or cleared across tunnels within the same name space? In fact,
>> do our security models even support name spaces?
>
> They don't support namespaces, and maintaining the label is critical =
for
> SELinux, at least, which mediates security for the system as a whole.
Herbert, could you send a v4 of your patch with the secmark included?
