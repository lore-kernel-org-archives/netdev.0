From: Marc Haber <mh+kernel-bugzilla@zugschlus.de>
Subject: Re: Fw: [Bugme-new] [Bug 4177] New: Please consider adding possibility to have multiple PPPoE sessions with different MAC addresses
Date: Sun, 6 Feb 2005 22:25:00 +0100
Message-ID: <20050206212500.GF17682@torres.l21.ma.zugschlus.de>
References: <20050206122604.74a41796.akpm@osdl.org> <1107723057.1055.28.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1107723057.1055.28.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Feb 06, 2005 at 03:50:57PM -0500, jamal wrote:
> Does that patch help at all?

It helps with the user space pppoed, yes.

> Seems to me all it enables is session setup, but after that what
> happens? Do packets go out with the MAC address you just spoofed
> for the data as well?

With user space pppoed, yes. When applied to the normal pppd, using
kernel pppoe, only session setup goes out with the fake MAC, and this
doesn't lead to a useable pppoe session, of course.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 621 72739835
