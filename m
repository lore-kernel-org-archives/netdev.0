From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next v2 01/10] net: dsa: lan9303: Fixed MDIO interface
Date: Fri, 28 Jul 2017 13:08:25 +0200
Message-ID: <4e36827f-fdcc-d55a-3559-e080883c715c@egil-hjelmeland.no>
References: <20170725161553.30147-1-privat@egil-hjelmeland.no>
 <20170725161553.30147-2-privat@egil-hjelmeland.no>
 <20170726165550.GN12049@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: corbet@lwn.net, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, davem@davemloft.net, kernel@pengutronix.de,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20170726165550.GN12049@lunn.ch>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26. juli 2017 18:55, Andrew Lunn wrote:
> On Tue, Jul 25, 2017 at 06:15:44PM +0200, Egil Hjelmeland wrote:
> It is better to use mdiobus_read/write or if you are nesting mdio
> busses, mdiobus_read_nested/mdiobus_write_nested. Please test this
> code with lockdep enabled.
> 

I have CONFIG_DEBUG_SPINLOCK, CONFIG_DEBUG_MUTEXES. Should I enable
more?

Egil
