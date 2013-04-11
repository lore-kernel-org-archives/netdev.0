From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 0/2] net: mv643xx_eth: use managed clk and allocation
Date: Thu, 11 Apr 2013 11:32:14 +0200
Message-ID: <5166831E.9090105@openwrt.org>
References: <1365672574-31123-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	Rob Landley <rob@landley.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1365672574-31123-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 04/11/13 11:29, Sebastian Hesselbarth a =C3=A9crit :
> With introduction of common clock framework and the ability to provid=
e
> gated clocks, mv643xx_eth required calls to get and enable these cloc=
k
> gates on some platforms. Back then, common clock framework api wasn't
> safe for architectures without support for common clocks. This has
> changed now and there are also managed (devm_) counterparts for clock
> related functions.
>
> The second patch in this series, also converts kzalloc to devm_kzallo=
c
> where applicable.
>
> Both patches have been sent to the corresponding mailing lists as
> individual patches before. To get the order required to apply them ri=
ght,
> this patch set combines both patches into one set.
>
> Sebastian Hesselbarth (2):
>    net: mv643xx_eth: add shared clk and cleanup existing clk handling
>    net: mv643xx_eth: use managed devm_kzalloc

Looks good, thanks Sebastian!

Acked-by: Florian Fainelli <florian@openwrt.org>
--
=46lorian
