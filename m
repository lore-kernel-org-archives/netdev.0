From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net] tcp: avoid multiple ssthresh reductions in on
 retransmit window
Date: Tue, 17 Jun 2014 14:20:38 +0200
Message-ID: <20140617122038.GA7275@unicorn.suse.cz>
References: <CAK6E8=dwh1btNzX80YNre9u7rS+SgochXxHxDhQYQZCvY8yVMQ@mail.gmail.com>
 <20140616211954.6E12BA3A89@unicorn.suse.cz>
 <CAK6E8=dxszKmHssR7ib7Fxfm6hQRdbwBG1ygRvOXoSAXddBSPA@mail.gmail.com>
 <CADVnQy=sd2V2A5Rzd+OtcH1a+un3-fATSn_acKdMKUcdbpGadg@mail.gmail.com>
 <CAK6E8=fb0x5Z0dnA6PDbxJKYn3z1y42Pr555t7apLbT97R8O-Q@mail.gmail.com>
 <CADVnQykk0pmryWdRjq21OXYK3Pvi5xWCkaB7Jf2acF5qtnzANg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yuchung Cheng <ycheng@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:50456 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932223AbaFQMUk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2014 08:20:40 -0400
Content-Disposition: inline
In-Reply-To: <CADVnQykk0pmryWdRjq21OXYK3Pvi5xWCkaB7Jf2acF5qtnzANg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 16, 2014 at 08:44:04PM -0400, Neal Cardwell wrote:
> On Mon, Jun 16, 2014 at 8:25 PM, Yuchung Cheng <ycheng@google.com> wrote:
> > However Linux is inconsistent on the loss of a retransmission. It
> > reduces ssthresh (and cwnd) if this happens on a timeout, but not in
> > fast recovery (tcp_mark_lost_retrans). We should fix that and that
> > should help dealing with traffic policers.
> 
> Yes, great point!

Does it mean the patch itself would be acceptable if the reasoning in
its commit message was changed? Or would you prefer a different way to
unify the two situations?

                                                        Michal Kubecek
