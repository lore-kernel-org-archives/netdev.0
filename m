From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [PATCH 2/6] net: dsa: allow switch drivers to cleanup their
 resources
Date: Tue, 27 Oct 2015 16:43:45 +0100
Message-ID: <562F9BB1.8090700@baylibre.com>
References: <562F8ED7.2000804@baylibre.com> <562F9AAB.8090202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Frode Isaksen <fisaksen@baylibre.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <562F9AAB.8090202@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
On 10/27/2015 04:39 PM, Florian Fainelli wrote:
> On 27/10/15 07:48, Neil Armstrong wrote:
>> Some switch drivers might request interrupts, remap register ranges,
>> allow such drivers to implement a "remove" callback doing just that.
>>
>> Suggested-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> This should probably be a Signed-off-by tag, but there is nothing using
> this, so you would want to introduce an user of this function in the
> same patch series so we see how you intend to use it?
> 
>> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>

Yes, I didn't know how to handle this since it was part of a larger patch.

I forgot to add this into the cover-letter but I wanted to send an RFC serie with
your bcm remove patch and a mv88e6xxx remove experimental code.

Yet, the mv88e6060 does not make usage of this.

Neil
