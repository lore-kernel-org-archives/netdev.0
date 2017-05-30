From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [net-wireless-orinoco] question about potential null pointer
 dereference
Date: Tue, 30 May 2017 21:37:01 +0200
Message-ID: <1496173021.3327.15.camel@sipsolutions.net>
References: <20170530120032.Horde.GHW0X8-B795CdxPjQOfDPa9@gator4166.hostgator.com>
         (sfid-20170530_190112_685275_C191B893)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170530120032.Horde.GHW0X8-B795CdxPjQOfDPa9@gator4166.hostgator.com> (sfid-20170530_190112_685275_C191B893)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> The issue here is that line 56 implies that pointer tfm_michael
> might be NULL. If this is the case, there is a potential NULL
> pointer dereference at line 52 once pointer tfm_michael is
> indirectly dereferenced inside macro SHASH_DESC_ON_STACK().
> 
> My question is if there is any chance that pointer tfm_michael
> might be NULL when calling macro SHASH_DESC_ON_STACK() ?
> 
> I'm trying to figure out if this is a false positive or something
> that needs to be fixed somehow.

Look, if you're just sending the coverity reports to the list without
reflecting and researching them, that's not actually useful - we can
look at them ourselves.

It took me at most a few minutes to figure this one out, so please just
do the same, look at the code, and figure out what the right answer is
here.

johannes
