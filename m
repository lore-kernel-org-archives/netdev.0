From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: netlink nlmsg_pid supposed to be pid or tid?
Date: Tue, 22 Nov 2005 00:35:49 +0300
Message-ID: <20051121213549.GA28187@ms2.inr.ac.ru>
References: <438220C3.4040602@nortel.com> <E1EeIcx-0006i3-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christopher Friesen <cfriesen@nortel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750956AbVKUVgX@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1EeIcx-0006i3-00@gondolin.me.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> I tend to agree with you here that tgid makes more sense.

I agree, apparently netlink_autobind was missed when sed'ing pid->tgid.
Of course, it does not matter, but tgid is nicer choice from user's viewpoint.

Alexey
