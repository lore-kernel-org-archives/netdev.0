From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next v2 0/8] net: extend ethtool link mode bitmaps
 to 48 bits
Date: Tue, 6 Jan 2015 15:56:33 +0200
Message-ID: <54ABE991.3040107@mellanox.com>
References: <1420512850-24699-1-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: David Decotigny <decot@googlers.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Ben Hutchings <ben@decadent.org.uk>,
	"Masatake YAMATO" <yamato@redhat.com>, Xi Wang <xii@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	WANG Cong <xiyou.wangcong@gmail.com>,
	Flavio Leitner <fbl@redhat.com>, Tom Gundersen <teg@jklm.no>,
	Jiri Pirko <jiri@resnulli.us>,
	Vlad Yasevich <vyasevic@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: David Decotigny <ddecotig@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
	Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0072.outbound.protection.outlook.com ([157.55.234.72]:9918
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754692AbbAFN5l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2015 08:57:41 -0500
In-Reply-To: <1420512850-24699-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/6/2015 4:54 AM, David Decotigny wrote:
> This patch series increases the width of the supported/advertising
> ethtool masks from 32 bits to 48. This should allow to breathe for a
> couple more years (or... months?).
Hi,

Nice work.
What worries me is that it is going to be for weeks more than years or
months...

Mellanox is about to release next month a driver for a new NIC, with 3
new speeds * few link modes for each + new link modes for 10G.
It seems that we will need to consume almost all the new bits.

Amir
