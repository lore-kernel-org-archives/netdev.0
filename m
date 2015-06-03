From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC 7/9] net: dsa: mv88e6352: lock CPU port from learning
 addresses
Date: Tue, 2 Jun 2015 21:06:15 -0400 (EDT)
Message-ID: <1317462817.952931.1433293575321.JavaMail.zimbra@savoirfairelinux.com>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1433208470-25338-8-git-send-email-vivien.didelot@savoirfairelinux.com> <556DBCA4.10203@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	=?utf-8?Q?J=C3=A9rome?= Oufella
	<jerome.oufella@savoirfairelinux.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>,
	Chris Healy <cphealy@gmail.com>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <556DBCA4.10203@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Guenter,

On Jun 2, 2015, at 10:24 AM, Guenter Roeck linux@roeck-us.net wrote:
On 06/01/2015 06:27 PM, Vivien Didelot wrote:
>> This commit disables SA learning and refreshing for the CPU port.
>>
> 
> Hi Vivien,
> 
> This patch also seems to be unrelated to the rest of the series.
> 
> Can you add an explanation why it is needed ?
> 
> With this in place, how does the CPU port SA find its way into the fdb ?
> Do we assume that it will be configured statically ?
> An explanation might be useful.

Without this patch, I noticed the CPU port was stealing the SA of a PC
behind a switch port. this happened when the port was a bridge member,
as the bridge was relaying broadcast coming from one switch port to the
other switch ports in the same vlan.

Thanks,
-v
