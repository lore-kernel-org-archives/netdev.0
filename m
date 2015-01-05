From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH net-next] Allow to set net namespace for wireless device
 via RTM_LINK
Date: Mon, 05 Jan 2015 10:22:04 +0100
Message-ID: <1420449724.1898.1.camel@sipsolutions.net>
References: <1410467723-2550-1-git-send-email-vadim4j@gmail.com>
	 <1411075535.2034.5.camel@jlt4.sipsolutions.net>
	 <20141014121627.GA5115@angus-think.lan>
	 <1413798437.10246.12.camel@jlt4.sipsolutions.net>
	 <128188DF-5A9B-47A5-8A89-974CF7CF9064@holtmann.org>
	 <1413802344.10246.20.camel@jlt4.sipsolutions.net>
	 <CAMw6YJKLWQmT-fqg1QLDHbCxnpxWyJUSX+wvOB_pFyE=8HfSfQ@mail.gmail.com>
	 (sfid-20141224_104849_030943_677BDE3C)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Vadim Kochan <vadim4j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMw6YJKLWQmT-fqg1QLDHbCxnpxWyJUSX+wvOB_pFyE=8HfSfQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20141224_104849_030943_677BDE3C)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-12-24 at 11:48 +0200, Vadim Kochan wrote:

>     1) Set NETIF_F_NETNS_LOCAL for phy wireless device only if there
> is at least one virtual interface which was created on it

You mean at least two? I'd think the behaviour becomes hard to predict,
but I guess ultimately that'd be somewhat reasonable.

>     2) What about to inherit netns for newer created interfaces from
> the phy device ?

Hmm? This already happens - a given phy is only in a single netns and
all interfaces must be created in the same netns.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
