From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH v2 1/2] net: ethernet: nb8800: Reset HW block in
 ndo_open
Date: Wed, 2 Aug 2017 15:54:37 +0200
Message-ID: <20170802135437.GA25781@lunn.ch>
References: <33d1ab47-6098-5e3f-8a3c-f72626d07113@free.fr>
 <d817da35-f977-5985-4aae-73617004fac3@free.fr>
 <yw1xbmnyi660.fsf@mansr.com>
 <ef36cd4a-b1b5-7505-34d1-250c736d6731@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mans Rullgard <mans@mansr.com>, netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49173 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752036AbdHBNym (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Aug 2017 09:54:42 -0400
Content-Disposition: inline
In-Reply-To: <ef36cd4a-b1b5-7505-34d1-250c736d6731@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Finally, you still haven't explained why the hw needs to be reset in
> > ndo_open().  Whatever is causing your lockup can almost certainly be
> > triggered in some other way too.  I will not accept this side-stepping
> > of the issue.
> 
> (I was not aware that you were the final authority on which
> patches are accepted upstream.)

./scripts/get_maintainer.pl -f drivers/net/ethernet/aurora/nb8800.c
"David S. Miller" <davem@davemloft.net> (commit_signer:6/6=100%)
Mans Rullgard <mans@mansr.com> (commit_signer:2/6=33%)
Jarod Wilson <jarod@redhat.com> (commit_signer:1/6=17%,authored:1/6=17%,removed_lines:1/17=6%)
Stephen Hemminger <stephen@networkplumber.org> (commit_signer:1/6=17%)
Florian Fainelli <f.fainelli@gmail.com> (commit_signer:1/6=17%,added_lines:1/14=7%,removed_lines:11/17=65%)
Javier Martinez Canillas <javier@osg.samsung.com> (authored:1/6=17%,added_lines:1/14=7%)
Johan Hovold <johan@kernel.org> (authored:1/6=17%,added_lines:7/14=50%,removed_lines:2/17=12%)
Johannes Berg <johannes.berg@intel.com> (authored:1/6=17%,added_lines:2/14=14%,removed_lines:2/17=12%)
Wei Yongjun <weiyongjun1@huawei.com> (authored:1/6=17%,added_lines:3/14=21%,removed_lines:1/17=6%)

David is very likely to listen to Mans's recommendations, since Mans
has done most of the review work for this driver.

      Andrew
