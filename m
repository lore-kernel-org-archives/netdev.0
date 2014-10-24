From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 06/14] net: dsa: Add support for hardware monitoring
Date: Fri, 24 Oct 2014 06:53:57 -0700
Message-ID: <544A59F5.4070705@roeck-us.net>
References: <1414037002-25528-1-git-send-email-linux@roeck-us.net> <1414037002-25528-7-git-send-email-linux@roeck-us.net> <CAGVrzcYjPJWai9bxkh+WRrEEAzBKBd-LQm7zDeeouxngr_v9SQ@mail.gmail.com> <54488CE1.2000106@roeck-us.net> <20141023134706.GB25190@lunn.ch> <20141023162754.GA21343@roeck-us.net> <20141023165459.GE25190@lunn.ch> <20141023173847.GA22988@roeck-us.net> <20141023180357.GG25190@lunn.ch> <20141023184322.GA24281@roeck-us.net> <20141023195526.GH25190@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141023195526.GH25190@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/23/2014 12:55 PM, Andrew Lunn wrote:
[ ... ]
>
> Does hwmon offer a function to sanitise a string?
>
No, that wasn't necessary so far. The 'name' string is a constant strin=
g
provided by the driver.

> The switch index definitely should be used and i would probably
> combine that with a sanitised version of the ethernet device name and
> "dsa".
>

How is this ?

em1dsa0-isa-0000
Adapter: ISA adapter
temp1:        +38.0=B0C  (high =3D +100.0=B0C)

This is the sanitized network device name + 'dsa' + index.

Guenter
