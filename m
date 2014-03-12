From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH V2 bluetooth-next 2/6] bluetooth: Convert uses of
 __constant_<foo> to <foo>
Date: Wed, 12 Mar 2014 11:22:34 -0700
Message-ID: <1394648554.3915.22.camel@joe-AO722>
References: <cover.1394643455.git.joe@perches.com>
	 <51892631f2289665bf47b294c783ee9560a8317e.1394643455.git.joe@perches.com>
	 <F2E9571C-2D55-4529-A361-D8CD4B3FC491@holtmann.org>
	 <1394646755.3915.8.camel@joe-AO722>
	 <34E193D0-F15B-4C23-83F7-697096916D4D@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"bluez mailin list (linux-bluetooth@vger.kernel.org)"
	<linux-bluetooth@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <34E193D0-F15B-4C23-83F7-697096916D4D@holtmann.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-03-12 at 11:11 -0700, Marcel Holtmann wrote:

> > 	/* Connection accept timeout ~20 secs */
> > -	param = __constant_cpu_to_le16(0x7d00);
> > +	param = cpu_to_le16(0x7d00);
> > 
> > 0x7d00 is 32000, presumably that's 32 seconds.
> 
> so it is 0x7d00 * 0.625 which results in 20 seconds.

Hi again Marcel.

Swell.  No worries then.

Is this clocking divisor defined somewhere?
Is .625 or 5/8 as a magic number defined somewhere?
(I didn't see it in a brief scan)
Maybe it'd be better to use 20000 * 5 / 8 or
add some define like

#define msecs_to_bt_clocks(ms) ((ms) * 5 / 8)

> > and
> > 		/* 160 msec page scan interval */
> > -		acp.interval = __constant_cpu_to_le16(0x0100);
> > +		acp.interval = cpu_to_le16(0x0100);
> > 256 msecs?
> 
> also here 0x0100 * 0.625 resulting in 160 msecs.

Same as above.

> patch has been applied to bluetooth-next tree.

cheers, Joe
