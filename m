From: "Tomas Winkler" <tomas.winkler@intel.com>
Subject: Re: [2.6.25 patch] fix broken error handling in ieee80211_sta_process_addba_request()
Date: Wed, 20 Feb 2008 10:38:04 +0200
Message-ID: <1ba2fa240802200038l79ae3b31na7604c2fb692929@mail.gmail.com>
References: <20080219225852.GQ31955@cs181133002.pp.htv.fi>
	 <20080220064613.GA3885@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Adrian Bunk" <bunk@kernel.org>,
	"Ron Rindjunsky" <ron.rindjunsky@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.227]:49238 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753176AbYBTIiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 03:38:06 -0500
Received: by wx-out-0506.google.com with SMTP id h31so2082921wxd.4
        for <netdev@vger.kernel.org>; Wed, 20 Feb 2008 00:38:05 -0800 (PST)
In-Reply-To: <20080220064613.GA3885@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Feb 20, 2008 8:46 AM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> On 19-02-2008 23:58, Adrian Bunk wrote:
> ...
> > --- a/net/mac80211/ieee80211_sta.c
> > +++ b/net/mac80211/ieee80211_sta.c
> > @@ -1116,9 +1116,10 @@ static void ieee80211_sta_process_addba_request(struct net_device *dev,
> ...
> > +                     printk(KERN_ERR "can not allocate reordering buffer "
>
>   +                     printk(KERN_ERR "cannot allocate reordering buffer "
>
> Probably this can be fixed during the commit.
>
> Jarek P
.
ACK: both patches.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
