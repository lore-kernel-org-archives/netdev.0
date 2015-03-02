From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] cosa.c : Array index 'i' is used before limits check.
Date: Mon, 02 Mar 2015 17:16:15 +0300
Message-ID: <54F470AF.6050401@cogentembedded.com>
References: <1424807546-10013-1-git-send-email-ameenali023@gmail.com> <54ECD78F.7040607@cogentembedded.com> <20150302130652.GX19534@fi.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ameen Ali <ameenali023@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jan Kasprzak <kas@fi.muni.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150302130652.GX19534@fi.muni.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 3/2/2015 4:06 PM, Jan Kasprzak wrote:

> : >avoid out-of-bounds-read by checking count before indexing.
> :
> : >Signed-off-by: Ameen Ali <Ameenali023@gmail.com>
> : >---
> : >  drivers/net/wan/cosa.c | 2 +-
> : >  1 file changed, 1 insertion(+), 1 deletion(-)
> :
> : >diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
> : >index 83c39e2..5252e21 100644
> : >--- a/drivers/net/wan/cosa.c
> : >+++ b/drivers/net/wan/cosa.c
> : >@@ -376,7 +376,7 @@ static int __init cosa_init(void)
> : >  	}
> : >  	for (i=0; i<MAX_CARDS; i++)
> : >  		cosa_cards[i].num = -1;
> : >-	for (i=0; io[i] != 0 && i < MAX_CARDS; i++)
> : >+	for (i=0; (i < MAX_CARDS) && (io[i] != 0) ; i++)

> :    Parens you've added aren't necessary.

> 	Yes, but I am OK with both variants.

    Anyway, space before ; should be removed (just noticed).

> :    I suggest to add spaces after and before = in the first expression.

> 	In that case, also the upper for() cycle should be modified
> to match this. I don't think this is necessary.

    As long as it doesn't cause complaints from scripts/checkpatch.pl...

> -Yenya

WBR, Sergei
