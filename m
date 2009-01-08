From: mysql.jorge@decimal.pt
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!
     2.6.28
Date: Thu, 8 Jan 2009 10:35:39 -0000 (WET)
Message-ID: <2025.192.168.1.3.1231410939.squirrel@webmail.decimal.pt>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt>
    <20090108094231.GD4496@ff.dom.local>
    <20090108095403.GE4496@ff.dom.local>
    <20090108100614.GA5418@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Denys Fedoryschenko" <denys@visp.net.lb>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrly03.isp.novis.pt ([195.23.133.213]:55459 "EHLO
	mailrly03.isp.novis.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786AbZAHKfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 05:35:25 -0500
In-Reply-To: <20090108100614.GA5418@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, even with that, why it works perfectly when i use the 100Mbit NIC?
There must be something here that needs an ajustment, no?




>>
>> Hmm... Actually, it's probably about config: I'm not cbq user or
>> expert, but AFAIK it depends on precise info about the real link
>> rate, so it probably needs an update to 1000Mbit.
>
> Hmm#2... I missed this tbf thing: this could point to GSO again, but
> generally it's considered as a bug to use more than one non-work-
> conserving qdisc in a tree (so e.g. cbq with any of tbf/htb/hfsc
> together).
>
> Jarek P.
>


