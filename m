From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dsa: mv88e6352/mv88e6xxx: Add support for Marvell
 88E6320 and 88E6321
Date: Thu, 09 Jul 2015 14:37:01 -0700 (PDT)
Message-ID: <20150709.143701.1788505384324235588.davem@davemloft.net>
References: <1436326695-18666-1-git-send-email-linux@roeck-us.net>
	<20150708145234.GB32208@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@roeck-us.net, netdev@vger.kernel.org, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org, ioctl@yandex.ru
To: andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150708145234.GB32208@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed, 8 Jul 2015 16:52:34 +0200

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

Please do not quote an entire patch just to add a reviewed-by or
acked-by tag.   If you have to quote some of the patch to comment
on specific portions, only quote exactly the hunks of the patch
relevant to what you want to discuss.

It doesn't take much effort to properly clip all except the most
relevant quoted text in your reply, and doing so I consider a very
basic common courtesy to everyone else on this mailing list.  It's
especially a courtesy to me as I have to scroll through the threads
and patchwork entries for every single patch posted here.

Thanks in advance for your consideration.
