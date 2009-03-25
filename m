From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] net: release dst entry in dev_queue_xmit()
Date: Wed, 25 Mar 2009 21:28:37 +0100
Message-ID: <49CA93F5.0@cosmosbay.com>
References: <49C380A6.4000904@cosmosbay.com> <20090324.234354.43714160.davem@davemloft.net> <49C9D99A.2040900@cosmosbay.com> <20090325.001720.238121238.davem@davemloft.net> <49CA7658.4010400@gmail.com> <49CA7AD7.8040401@cosmosbay.com> <20090325191850.GA2928@ami.dom.local> <49CA8895.8020105@cosmosbay.com> <20090325195424.GB2928@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58679 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754071AbZCYU2s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 16:28:48 -0400
In-Reply-To: <20090325195424.GB2928@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :

> I guess you've considered the loopback too...
>=20

I had for the first patch (carefuly avoiding loopback being not respons=
ive) :
I was releasing dst only if enqueue() was called.

You are right, loopback doesnt work anymore with last patch,
and I have no idea why...

Do you know why ?

Thank you

