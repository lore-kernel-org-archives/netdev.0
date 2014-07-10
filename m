From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [PATCH v7 15/33] net: xen-netback - set name assign type
Date: Thu, 10 Jul 2014 10:01:26 +0100
Message-ID: <1404982886.30660.4.camel@hastur.hellion.org.uk>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
	 <1404980258-30853-16-git-send-email-teg@jklm.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Wei Liu <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>
To: Tom Gundersen <teg@jklm.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404980258-30853-16-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-07-10 at 10:17 +0200, Tom Gundersen wrote:
> The name contains then xen handle, which is not guaranteed to be
> stable between restarts, so label this NET_NAME_ENUM.

FWIW the N'th interface for domain with domid D will always be named
vifD.N.

If you reboot domain D then it's domid will change to E and the new
device will be vifE.N.

I don't know if that counts as predictable as far as the interface you
are introducing is concerned.

Ian.
