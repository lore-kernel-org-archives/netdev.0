From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net: modify tunnel's name when changing link's name
Date: Wed, 21 May 2014 09:16:49 +0900
Message-ID: <20140521091649.78487d50@samsung-9>
References: <537AE7D1.4090702@cn.fujitsu.com>
	<CAHA+R7O-yr5w6T2PUMXyofyZxmyyaGPSBUN67WTMVdvogmSmmA@mail.gmail.com>
	<CAHA+R7Oc6qwd82riF8T+wXyopfMP9RquKUXty6WUpGs-n5ac5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Duan Jiong <duanj.fnst@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:63860 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210AbaEUARA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 20:17:00 -0400
Received: by mail-pb0-f45.google.com with SMTP id um1so815086pbc.4
        for <netdev@vger.kernel.org>; Tue, 20 May 2014 17:16:59 -0700 (PDT)
In-Reply-To: <CAHA+R7Oc6qwd82riF8T+wXyopfMP9RquKUXty6WUpGs-n5ac5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 May 2014 16:20:31 -0700
Cong Wang <cwang@twopensource.com> wrote:

> On Tue, May 20, 2014 at 12:21 PM, Cong Wang <cwang@twopensource.com> wrote:
> >
> > I am working on a patch.
> 
> For now, I think we just fix the renaming issue.
> Please try this patch below (I already tested it actually).
> 
> IPv6 part is on the way.

Would it be possible for tunnel params name to point to dev->name
instead of having to keep a copy up to date?
