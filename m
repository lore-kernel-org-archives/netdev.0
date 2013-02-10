From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] skbuff: create skb_panic() to let caller specify panic
Date: Sat, 09 Feb 2013 22:02:53 -0800
Message-ID: <1360476173.26127.3.camel@joe-AO722>
References: <1360471749-6177-1-git-send-email-sakiwit@gmail.com>
	 <1360473061.26127.1.camel@joe-AO722> <20130210055629.GB2496@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:56729 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751513Ab3BJGCz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Feb 2013 01:02:55 -0500
In-Reply-To: <20130210055629.GB2496@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-02-09 at 22:56 -0700, Jean Sacren wrote:
> From: Joe Perches <joe@perches.com>
> > Don't split the format across multiple lines please.
[]
> Honestly I didn't want to split the whole string, but I was in the
> dilemma of accommodating 80-column convention. I'm ready to respin if
> the consensus favors one long string. But how long is too long?

Documentation/CodingStyle

		Chapter 2: Breaking long lines and strings
...
never break user-visible strings such as printk messages,
because that breaks the ability to grep for them
