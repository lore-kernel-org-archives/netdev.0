From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.18-mm1 -- ieee80211: Info elem: parse failed:
 info_element->len + 2 > left : info_element->len+2=28 left=9, id=221.
Date: Tue, 26 Sep 2006 12:43:10 -0700
Message-ID: <20060926124310.17797fe5.akpm@osdl.org>
References: <a44ae5cd0609261204g673fbf8ft6809378930986eac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	"Jouni Malinen" <jkmaline@cc.hut.fi>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:16846 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932493AbWIZTnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 15:43:18 -0400
To: "Miles Lane" <miles.lane@gmail.com>, netdev@vger.kernel.org
In-Reply-To: <a44ae5cd0609261204g673fbf8ft6809378930986eac@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[added netdev]

On Tue, 26 Sep 2006 12:04:40 -0700
"Miles Lane" <miles.lane@gmail.com> wrote:

> ieee80211: Info elem: parse failed: info_element->len + 2 > left :
> info_element->len+2=28 left=9, id=221.
> ieee80211: Info elem: parse failed: info_element->len + 2 > left :
> info_element->len+2=28 left=9, id=221.
> ieee80211: Info elem: parse failed: info_element->len + 2 > left :
> info_element->len+2=28 left=9, id=221.
> 
> >From dmesg output:
> ieee80211: 802.11 data/management/control stack, git-1.1.13
> ieee80211: Copyright (C) 2004-2005 Intel Corporation <jketreno@linux.intel.com>
> ieee80211_crypt: registered algorithm 'NULL'
> ieee80211_crypt: registered algorithm 'WEP'
> ieee80211_crypt: registered algorithm 'CCMP'
> ieee80211_crypt: registered algorithm 'TKIP'

I suspect that whatever caused this is now in mainline.  Are you able to
test Linus's current git tree?

Thanks.
