From: David Miller <davem@davemloft.net>
Subject: Re: What's the status of TCP friends?
Date: Mon, 17 Mar 2014 23:52:32 -0400 (EDT)
Message-ID: <20140317.235232.1343586786531900880.davem@davemloft.net>
References: <20140317031605.GA22502@gmail.com>
	<20140318012120.GG12291@order.stressinduktion.org>
	<20140318031346.GA5142@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, bingtian.ly@taobao.com,
	edumazet@google.com, brutus@google.com, panweiping3@gmail.com,
	tmorvai@gmail.com
To: gnehzuil.liu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45961 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266AbaCRDwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 23:52:36 -0400
In-Reply-To: <20140318031346.GA5142@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zheng Liu <gnehzuil.liu@gmail.com>
Date: Tue, 18 Mar 2014 11:13:46 +0800

> Now our program needs a IPC mechansim that can commnucate between
> two servers and provide a high performance when two processes are
> run on the same server.

Using both TCP and AF_UNIX, as needed, and dynamically, is a technique
which has been in use for more than two decades by X.

Nothing stops you from adopting such a scheme too.

Usually when I someone says "I can't" it sounds to me more like "I've
decided to stop trying to think of a way to make it work."
