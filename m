From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rps: send IPIs ASAP
Date: Mon, 19 Apr 2010 22:39:36 -0700 (PDT)
Message-ID: <20100419.223936.193719455.davem@davemloft.net>
References: <1271736519-2991-1-git-send-email-xiaosuo@gmail.com>
	<g2y65634d661004192215oc06d9c43xb2a7c7d946149cf5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45605
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752913Ab0DTFje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 01:39:34 -0400
In-Reply-To: <g2y65634d661004192215oc06d9c43xb2a7c7d946149cf5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 19 Apr 2010 22:15:58 -0700

> Did you test this to see what the impact is in this regard?

Changli it would help immensely if you posted performance
test results along with your changes.

I can see quite obviously that this change will completely undo the
intentional batching of IPIs done by RPS.  IPIs are expensive and we
should batch things as much as possible here.
