From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 06/14] net: dsa: Add support for hardware monitoring
Date: Thu, 23 Oct 2014 15:47:06 +0200
Message-ID: <20141023134706.GB25190@lunn.ch>
References: <1414037002-25528-1-git-send-email-linux@roeck-us.net>
 <1414037002-25528-7-git-send-email-linux@roeck-us.net>
 <CAGVrzcYjPJWai9bxkh+WRrEEAzBKBd-LQm7zDeeouxngr_v9SQ@mail.gmail.com>
 <54488CE1.2000106@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54488CE1.2000106@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >>+static DEVICE_ATTR_RO(temp1_input);
> >
> >You probably want the number of temperature sensors to come from the
> >switch driver, and support arbitrary number of temperature sensors?
> 
> In that case we would need the number of sensors, pass a sensor index,
> and create a dynamic number of attributes. The code would get much more
> complex without real benefit unless there is such a chip 

We are two different use cases here:

One switch chip with multiple temperature sensors
Multiple switch chips, each with its own temperature sensor.

I don't know of any hardware using either of these uses cases, but
they could appear in the future.

If we are not doing the generic implementation now, how about avoiding
an ABI break in the future, by hard coding the sensors with .0.0 on
the end?

    Andrew
