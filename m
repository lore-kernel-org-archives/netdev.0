From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH 3/3] net: dsa: exit probe if no switch were found
Date: Thu, 1 Oct 2015 18:32:57 +0200
Message-ID: <20151001163257.GQ20219@lunn.ch>
References: <560B9B7C.9080406@baylibre.com>
 <560D50E4.6040400@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <560D50E4.6040400@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 01, 2015 at 05:27:32PM +0200, Neil Armstrong wrote:
> On 09/30/2015 10:21 AM, Neil Armstrong wrote:
> > If no switch were found in dsa_setup_dst, return -ENODEV and
> > exit the dsa_probe cleanly.

...
 
> Couldn't we use the probe defer mechanism here ? (until complete rework is done)

Hi Neil

I was thinking the same last night. We know the switch should be
there, otherwise it would not be in DT. So returning -EPROBE_DEFER
would be valid.

      Andrew
