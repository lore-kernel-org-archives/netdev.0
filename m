From: "David S. Miller" <davem@rth.ninka.net>
Subject: Re: [RESEND] tuning linux for high network performance?
Date: 23 Oct 2002 06:21:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1035379308.5950.3.camel@rth.ninka.net>
References: <200210231218.18733.roy@karlsbakk.net>
	<200210231306.18422.roy@karlsbakk.net>
	<20021023130101.GA646@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roy Sigurd Karlsbakk <roy@karlsbakk.net>, netdev@oss.sgi.com,
   Kernel
	mailing list <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20021023130101.GA646@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2002-10-23 at 06:01, bert hubert wrote:
> Also mention that you have an e1000 card which
> does not do outgoing checksumming.

The e1000 can very well do hardware checksumming on transmit.

The missing piece of the puzzle is that his application is not
using sendfile(), without which no transmit checksum offload
can take place.
