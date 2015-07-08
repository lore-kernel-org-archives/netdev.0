From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] dsa: mv88e6352/mv88e6xxx: Add support for Marvell 88E6320
 and 88E6321
Date: Wed, 08 Jul 2015 08:08:31 -0700
Message-ID: <559D3CEF.3070307@roeck-us.net>
References: <1436326695-18666-1-git-send-email-linux@roeck-us.net> <20150708145234.GB32208@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org,
	"Aleksey S. Kazantsev" <ioctl@yandex.ru>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150708145234.GB32208@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/08/2015 07:52 AM, Andrew Lunn wrote:
> On Tue, Jul 07, 2015 at 08:38:15PM -0700, Guenter Roeck wrote:
>> From: "Aleksey S. Kazantsev" <ioctl@yandex.ru>
>>
>> MV88E6320 and MV88E6321 are largely compatible to MV886352,
>> but are members of a different chip family.
>>
>> Signed-off-by: Aleksey S. Kazantsev <ioctl@yandex.ru>
>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
>
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
>
> One thing we might want to consider, is moving the temperate sensor
> code into mv88e6xxx. It seems likely future devices will also have the
> same sensor, so moving it to the shared code would make sense. We can
> then keep all mv88e6xxx_XXXX_family() stuff in a single file.
>
> I don't see this as a blocker for this patchset, but now might be the
> right time to do this.
>
Makes sense. Let's do it in a separate patch, though.
I'll do that in a couple of weeks, after I am back from vacation.

Thanks,
Guenter
