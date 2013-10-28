From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 16/16] wl1251: Add sysfs file address for setting
 permanent mac address
Date: Mon, 28 Oct 2013 15:56:55 +0100
Message-ID: <1382972215.17956.30.camel@jlt4.sipsolutions.net>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
	 <201310281449.58170@pali> <1382968522.17956.11.camel@jlt4.sipsolutions.net>
	 <201310281500.24159@pali> <1382971562.1542.6.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pali =?ISO-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>,
	Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382971562.1542.6.camel@dcbw.foobar.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-10-28 at 09:46 -0500, Dan Williams wrote:

> If the device doesn't actually *have* a permanent MAC address, then it
> shouldn't be returning one via ethtool, and should return an error for
> ETHTOOL_GPERMADDR.

There's currently no provision for that, but I agree it would be better
to do so.

johannes
