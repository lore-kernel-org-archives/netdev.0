From: jamal <j.hadi123@gmail.com>
Subject: Re: [PATCH] net: gen_estimator: Fix gen_kill_estimator() lookups
Date: Mon, 24 Nov 2008 08:18:45 -0500
Message-ID: <1227532725.22481.14.camel@dogo.mojatatu.com>
References: <20081124120404.GA16413@ff.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	jamal <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:20037 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616AbYKXNTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 08:19:05 -0500
Received: by yx-out-2324.google.com with SMTP id 8so814512yxm.1
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 05:19:03 -0800 (PST)
In-Reply-To: <20081124120404.GA16413@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-11-24 at 12:04 +0000, Jarek Poplawski wrote:
> gen_kill_estimator() linear lists lookups are very slow, and e.g. while
> deleting a large number of HTB classes soft lockups were reported. Here
> is another try to fix this problem: this time internally, with rbtree,
> so similarly to Jamal's hashing idea IIRC. (Looking for next hits could
> be still optimized, but it's really fast as it is.)

Certainly a big improvement. Compared to hashing i suggested:
the deletion speed is probably equal or better than using a hash.
I think a hash would have performed better in the case of addition
than the rb tree; but you primarily concerned about deletion, so this
good.

Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

cheers,
jamal

