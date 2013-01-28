From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] checkpatch.pl: Fix warnings on code comments
Date: Mon, 28 Jan 2013 09:30:28 -0800
Message-ID: <1359394228.31480.7.camel@joe-AO722>
References: <1359286539-18395-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20130127.185910.1743425400733006443.davem@davemloft.net>
	 <1359341805.2255.56.camel@jtkirshe-mobl>
	 <20130127.220728.634216960903942581.davem@davemloft.net>
	 <804857E1F29AAC47BF68C404FC60A1843ABC3058@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"apw@canonical.com" <apw@canonical.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <804857E1F29AAC47BF68C404FC60A1843ABC3058@ORSMSX102.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-01-28 at 17:17 +0000, Allan, Bruce W wrote:
> David Miller Sent: Sunday, January 27, 2013 7:07 PM
> > From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > > So will you be fine with cleanup patches which go through and
> > > convert all the existing code comments to the desired format?
> > Sure.
> Not all Intel drivers...e1000e already conforms to the comment style :-)

In case anyone cares, here's a perl regex
to do network comment style conversion.

	$text =~ s@/\*[ \t]*\n[ \t]*\*@/*@g;
	$text =~ s@/\*([ \t]*)([^\n]+)\n[ \t]*\*/@/\*$1$2 \*/@g;

(assumes the entire file is in $text)

It creates a ~220KB diff for drivers/net/ethernet/intel/
that I won't post.
