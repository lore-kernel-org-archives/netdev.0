From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3] ifb: move tq from ifb_private
Date: Sat, 04 Dec 2010 11:08:01 -0500
Message-ID: <1291478881.2159.70.camel@mojatatu>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
	 <1291442121-3302-3-git-send-email-xiaosuo@gmail.com>
	 <4CFA3F01.20109@gmail.com> <1291472889.2159.18.camel@mojatatu>
	 <1291474127.2159.35.camel@mojatatu>  <20101204154007.GA1981@del.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f42.google.com ([74.125.83.42]:56804 "EHLO
	mail-gw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755261Ab0LDQII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 11:08:08 -0500
Received: by gwb20 with SMTP id 20so5381967gwb.1
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 08:08:08 -0800 (PST)
In-Reply-To: <20101204154007.GA1981@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-12-04 at 16:40 +0100, Jarek Poplawski wrote:

> Hmm... But we didn't care until now... ;-) 

Well, if Changli didnt post - there would be no discussion ;->
The message was lost in the translation somewhere; events such as
patches sometimes serve as good reminders.

> Btw. is it really very
> probable (and worth bothering) that this current error of NULL dev
> get fixed before we purge this tq queue with deferral one by one?

Indeed - this is working against something buggy. But it has happened
often in the past. And the likelihood of there being a few bad ones
in the train of packets when this occurs is high. But there are many
packets there that wont suffer this sympton - so the only fair scheme is
to check all. Note: a BUG() seems unreasonable and the deferring  serves
as a throttling scheme.
What do you have in mind?

cheers,
jamal

