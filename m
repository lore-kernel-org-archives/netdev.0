From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] genetlink custom attribute type
Date: Mon, 02 Oct 2006 15:56:58 +0200
Message-ID: <1159797418.2655.71.camel@ux156>
References: <1159255520.2782.1.camel@ux156>
	 <20060926094408.GT18349@postel.suug.ch> <1159359523.2698.27.camel@ux156>
	 <20061002134913.GB18349@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:32669 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932341AbWJBN4O
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 09:56:14 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061002134913.GB18349@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-10-02 at 15:49 +0200, Thomas Graf wrote:

> That's not a bad idea, although it seems cleaner to just allow defining
> a callback function which gets called foreach unknown attribute.

Hm, that'd work too, but it'd force me to leave these 'unknown
attributes' at the end of the attribute space, no? Otherwise, something
with .len=0,.type=0 is sort of valid as well, not?

> As for
> generic netlink, this callback could be defined on a per command basis
> in struct genl_ops.

I'd have to look at it more closely again, I removed the custom stuff
and it's not immediately important to me at this time.

johannes
