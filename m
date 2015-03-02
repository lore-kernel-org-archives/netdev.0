From: Jan Kasprzak <kas@fi.muni.cz>
Subject: Re: [PATCH 2/2] cosa.c : Array index 'i' is used before limits check.
Date: Mon, 2 Mar 2015 14:06:52 +0100
Message-ID: <20150302130652.GX19534@fi.muni.cz>
References: <1424807546-10013-1-git-send-email-ameenali023@gmail.com>
 <54ECD78F.7040607@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ameen Ali <ameenali023@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.46]:33996 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751266AbbCBNH3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2015 08:07:29 -0500
Content-Disposition: inline
In-Reply-To: <54ECD78F.7040607@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sergei Shtylyov wrote:
: Hello.
: 
: On 02/24/2015 10:52 PM, Ameen Ali wrote:
: 
: >avoid out-of-bounds-read by checking count before indexing.
: 
: >Signed-off-by: Ameen Ali <Ameenali023@gmail.com>
: >---
: >  drivers/net/wan/cosa.c | 2 +-
: >  1 file changed, 1 insertion(+), 1 deletion(-)
: 
: >diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
: >index 83c39e2..5252e21 100644
: >--- a/drivers/net/wan/cosa.c
: >+++ b/drivers/net/wan/cosa.c
: >@@ -376,7 +376,7 @@ static int __init cosa_init(void)
: >  	}
: >  	for (i=0; i<MAX_CARDS; i++)
: >  		cosa_cards[i].num = -1;
: >-	for (i=0; io[i] != 0 && i < MAX_CARDS; i++)
: >+	for (i=0; (i < MAX_CARDS) && (io[i] != 0) ; i++)
: 
:    Parens you've added aren't necessary.

	Yes, but I am OK with both variants.

:    I suggest to add spaces after and before = in the first expression.

	In that case, also the upper for() cycle should be modified
to match this. I don't think this is necessary.

-Yenya

-- 
| Jan "Yenya" Kasprzak   <kas at {fi.muni.cz - work | yenya.net - private}> |
| New GPG 4096R/A45477D5 -- see http://www.fi.muni.cz/~kas/pgp-rollover.txt |
| http://www.fi.muni.cz/~kas/     Journal: http://www.fi.muni.cz/~kas/blog/ |
||| "New and improved" is only really improved if it also takes backwards |||
||| compatibility into account, rather than saying "now everybody must do |||
||| things the new and improved - and different - way"   --Linus Torvalds |||
