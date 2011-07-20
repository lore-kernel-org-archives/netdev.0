From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/3] wireless: rtlwifi: throw away MAC_FMT and use %pM
 instead
Date: Wed, 20 Jul 2011 09:02:42 -0700
Message-ID: <1311177762.1663.9.camel@Joe-Laptop>
References: <fddeabc04a1b81a5c1f51a4164d93366dccf5f8e.1311162926.git.andriy.shevchenko@linux.intel.com>
	 <4E26F879.8010601@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E26F879.8010601@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-07-20 at 10:47 -0500, Larry Finger wrote:
> Thanks for the patch.

Hey Larry.

rtlwifi has a CONFIG_BT_COEXIST which is currently
unused/undefined by Kconfig.

Are there plans to enable this or should the code
just be removed?

There may be a few dependencies in rtlwifi for
variables set in this block so it seems from
superficial reading that removal might be a bit
involved.  I didn't look much more than that,
but struct btcoexist_priv doesn't seem to be
specified by the code anywhere.
