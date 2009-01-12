From: "Jorge Bastos" <mysql.jorge@decimal.pt>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!
     2.6.28
Date: Mon, 12 Jan 2009 09:48:08 -0000 (WET)
Message-ID: <2105.192.168.1.3.1231753688.squirrel@webmail.decimal.pt>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt>
    <200901082357.13396.denys@visp.net.lb>
    <20090109103030.GI4605@ff.dom.local>
    <200901091232.09923.denys@visp.net.lb>
    <20090109104411.GJ4605@ff.dom.local>
    <1504.192.168.1.3.1231498031.squirrel@webmail.decimal.pt>
    <20090109105858.GA6098@ff.dom.local> <496AF0CE.7060406@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Jarek Poplawski" <jarkao2@gmail.com>,
	"Denys Fedoryschenko" <denys@visp.net.lb>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrly05.isp.novis.pt ([195.23.133.214]:43934 "EHLO
	mailrly05.isp.novis.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbZALJsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 04:48:16 -0500
In-Reply-To: <496AF0CE.7060406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Patrick,

>>
>> I guess not: it's about better resolution, so e.g. when 2% matters.
>> And it matters for a desktop box, if you care about responsiveness.
>
> Just wondering since this thread is very hard to follow with all
> the top postings, incorrect timestamps on mails etc. - has there
> been a resolution to this problem?
>

Top posting are my fault, sorry!
Yes for me got solved with disable GSO, TSO and SG.
With them disabled, CBQ+TCF works as expected.
My 100Mbit NIC always worked because this values were off by default,
that's Why i start posting that it worked with a 100Mbit NIC and not with
a 1000Mbit NIC, the reason were the values were off dby default.


