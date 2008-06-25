From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/8 v2] textsearch: fix Boyer-Moore text search bug
Date: Wed, 25 Jun 2008 12:57:06 +0200
Message-ID: <48622482.1040405@trash.net>
References: <> <1214389495-21325-1-git-send-email-joonwpark81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49848 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754691AbYFYK5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 06:57:11 -0400
In-Reply-To: <1214389495-21325-1-git-send-email-joonwpark81@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joonwoo Park wrote:
> The current logic has a bug which cannot find matching pattern, if the
> pattern is matched from the first character of target string.
> for example:
> 	pattern=abc, string=abcdefg
> 	pattern=a,   string=abcdefg
> Searching algorithm should return 0 for those things.

Since this patch fixes a bug, I've queued it for 2.6.26, thanks.
