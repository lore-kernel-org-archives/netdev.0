From: jamal <hadi@cyberus.ca>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Mon, 05 Nov 2007 09:06:29 -0500
Message-ID: <1194271589.4438.113.camel@localhost>
References: <1193939701.2987.82.camel@localhost.localdomain>
	 <472B5EF1.4020206@o2.pl> <1194045830.4438.21.camel@localhost>
	 <472D06B2.9040402@o2.pl> <472D0B1C.7000209@o2.pl> <472D128B.8030704@o2.pl>
	 <472D1DC2.9000106@o2.pl> <1194220693.4438.75.camel@localhost>
	 <20071105091231.GA1933@ff.dom.local>
	 <1194267561.2987.141.camel@localhost.localdomain>
	 <20071105135246.GB1933@ff.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Radu Rendec <radu.rendec@ines.ro>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:50101 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754854AbXKEOHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 09:07:31 -0500
Received: by wa-out-1112.google.com with SMTP id v27so1984046wah
        for <netdev@vger.kernel.org>; Mon, 05 Nov 2007 06:07:30 -0800 (PST)
In-Reply-To: <20071105135246.GB1933@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-05-11 at 14:52 +0100, Jarek Poplawski wrote:

> It seems this performance loss shouldn't be so big because ntohl()
> is probably quite well optimized in assembler. But, as I've written,
> since there is max. 1 byte meaningful to us there is some additional
> possibility to get it other way, but I doubt it's worth to bother,
> and this can be done with some later patch, after all.

Agreed on optimizing later. It will probably keep nagging at me for
sometime....

> If we manage to convince Jamal, IMHO a patch to something current like
> 2.6.24-rc1-git14 (or maybe -rc2 soon), should suffice (plus some
> options to diff to get function names etc. eg.: diff -Nurp). Try with
> Documentation/SubmittingPatches. Git isn't necessary at all. And don't
> forget about a changelog.

That code hasnt changed at all in a few years, so even against
2.6.24-rc1 should be fine and can be applied cleanly to Daves net-2.6.
Radu, please refer to my earlier email on things to try.

cheers,
jamal

