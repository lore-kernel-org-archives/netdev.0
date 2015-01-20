From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] rhashtable: rhashtable_remove() must unlink
 in both tbl and future_tbl
Date: Tue, 20 Jan 2015 21:44:09 +0300
Message-ID: <54BEA1F9.1050908@cogentembedded.com>
References: <54BCBA35.2080103@windriver.com> <20150119125928.GB7672@casper.infradead.org> <54BDC30D.5000606@windriver.com> <20150120165826.GK20315@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "richard.alpe@ericsson.com >> Richard Alpe"
	<richard.alpe@ericsson.com>, Netdev <netdev@vger.kernel.org>,
	tipc-discussion@lists.sourceforge.net
To: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net,
	Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:52013 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109AbbATSoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 13:44:24 -0500
Received: by mail-la0-f44.google.com with SMTP id s18so2783526lam.3
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 10:44:12 -0800 (PST)
In-Reply-To: <20150120165826.GK20315@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/20/2015 07:58 PM, Thomas Graf wrote:

> As removals can occur during resizes, entries may be referred to from
> both tbl and future_tbl when the removal is requested. Therefore
> rhashtable_remove() must unlink the entry in both tables if this is
> the case. The existing code did search both tables but stopped when it
> hit the first match.

> Failing to do so resulted in use after remove.

    Er, failing to do what? Stopping when it hit the first match?

> Fixes: 97defe1 ("rhashtable: Per bucket locks & deferred expansion/shrinking")

    SHA1 should be 12 hex digits in this case, accordong to 
Documentation/SubmittingPatches.

> Reported-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

[...]

WBR, Sergei
