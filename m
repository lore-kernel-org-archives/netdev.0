From: Joe Perches <joe@perches.com>
Subject: Re: [patch] isdn: icn: buffer overflow in icn_command()
Date: Wed, 16 Apr 2014 04:47:08 -0700
Message-ID: <1397648828.15177.9.camel@joe-AO722>
References: <20140414080756.GA13372@mwanda>
	 <1397490748.2803.18.camel@joe-AO722> <20140416111653.GF4963@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20140416111653.GF4963@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-04-16 at 14:16 +0300, Dan Carpenter wrote:

> snprintf() returns the number of bytes which would have been printed if
> there were enough space and not the number of bytes in the string.
> Using the value from snprintf() would not introduce a bug because I have
> carefully counted the number of bytes in the output string, but it would
> hopefully annoy human auditors of this code.  ;)  You are thinking of
> scnprintf().

Not really, I was assuming you'd use max() too
but you're right, scnprintf is more sensible.

> I'm going to apply your minimal changes suggestion here.

swell, thanks

