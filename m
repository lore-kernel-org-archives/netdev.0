From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] niu: improve ethtool support for gigabit copper
	cards
Date: Tue, 17 Feb 2009 13:53:57 +0000
Message-ID: <1234878837.3183.4.camel@achroite>
References: <20090217154334.97837477.baranov@mercdev.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Constantin Baranov <baranov@mercdev.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753141AbZBQNyW@vger.kernel.org>
In-Reply-To: <20090217154334.97837477.baranov@mercdev.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-02-17 at 15:43 +0400, Constantin Baranov wrote:
> Introduced support for link speed and duplex setting (ethtool -s),
> link advertising parameters and autonegotiation (ethtool -r):
[...]

I haven't looked closely at this, but is there anything here that can't
be handled by mii_get_settings() and other functions in the mii driver?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
