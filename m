From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] bridge: skip fdb add if the port shouldn't
 learn
Date: Tue, 26 May 2015 10:28:09 -0700
Message-ID: <20150526102809.5c3e8abc@urahara>
References: <1432204977-4293-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wkok@cumulusnetworks.com,
	davem@davemloft.net, bridge@lists.linux-foundation.org
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35371 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105AbbEZR2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 13:28:06 -0400
Received: by pacwv17 with SMTP id wv17so97597852pac.2
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 10:28:06 -0700 (PDT)
In-Reply-To: <1432204977-4293-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 May 2015 03:42:57 -0700
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> From: Wilson Kok <wkok@cumulusnetworks.com>
> 
> Check in fdb_add_entry() if the source port should learn, similar
> check is used in br_fdb_update.
> Note that new fdb entries which are added manually or
> as local ones are still permitted.
> This patch has been tested by running traffic via a bridge port and
> switching the port's state, also by manually adding/removing entries
> from the bridge's fdb.
> 
> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

What is the problem this is trying to solve?

I think user should be allowed to manually add any entry
even if learning.
