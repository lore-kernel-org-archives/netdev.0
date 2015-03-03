From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: bridge: add compile-time assert for cb struct
 size
Date: Tue, 03 Mar 2015 06:33:25 -0800
Message-ID: <1425393205.5130.184.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425387211-16807-1-git-send-email-fw@strlen.de>
	 <063D6719AE5E284EB5DD2968C1650D6D1CAF3BB7@AcuExch.aculab.com>
	 <1425391664.5130.174.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CAF3C01@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Florian Westphal' <fw@strlen.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:44324 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756422AbbCCOd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 09:33:27 -0500
Received: by igdh15 with SMTP id h15so28152026igd.3
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 06:33:27 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAF3C01@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-03-03 at 14:15 +0000, David Laight wrote:

> That is a build error.

Yes, but we want a build error that this obvious to understand.

Like :

BUILD_BUG_ON(sizeof(struct br_input_skb_cb) > FIELD_SIZEOF(struct sk_buff, cb));

Please send a tested patch so that we can compare the solutions.
