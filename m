From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Multicast snooping fixes and suggestions
Date: Thu, 24 Feb 2011 12:04:12 +0800
Message-ID: <20110224040412.GA25488@gondor.apana.org.au>
References: <1297811961-19249-1-git-send-email-linus.luessing@web.de> <4D65CD81.4070203@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus =?iso-8859-1?Q?L=FCssing?= <linus.luessing@web.de>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D65CD81.4070203@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 23, 2011 at 07:16:17PM -0800, H. Peter Anvin wrote:
>
> Are these packets likely to address that situation (or am I just plain
> doing something stupid)?

No these patches deal with IPv6 multicast support in the bridge and
are not related to your problem.

If you're using the bridge for virtualisation and you know that
you don't have a loop in your setup, then one option would be to
disable STP on your bridge.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
