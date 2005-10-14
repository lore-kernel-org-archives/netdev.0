From: Frank Sorenson <frank@tuxrocks.com>
Subject: Re: Kconfig Dependencies for CONFIG_NET_CLS_RSVP6
Date: Fri, 14 Oct 2005 01:07:44 -0600
Message-ID: <434F5940.9010500@tuxrocks.com>
References: <434F5247.2040007@tuxrocks.com> <20051013.235907.66789139.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932219AbVJNHH4@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20051013.235907.66789139.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

David S. Miller wrote:
> From: Frank Sorenson <frank@tuxrocks.com>
> Date: Fri, 14 Oct 2005 00:37:59 -0600
> 
> 
>>I noticed that I can still select "Special RSVP classifier for IPv6"
>>even if "The IPv6 protocol" isn't selected.  Should CONFIG_NET_CLS_RSVP6
>>depend on or select IPV6?
>>
>>Currently:
>>Depends on: NET && NET_CLS && NET_QOS
> 
> 
> It doesn't need the ipv6 stack at all, it's just a classifier
> that looks at packet headers and makes decisions.

Okay, I suppose that makes more sense now.  I just wanted to check it
through, since I figured I'd turned off everything related to IPv6 :)

Thanks for explaining,

Frank
- --
Frank Sorenson - KD7TZK
Systems Manager, Computer Science Department
Brigham Young University
frank@tuxrocks.com
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFDT1lAaI0dwg4A47wRAuXVAKCWBcZj3OTK8wLZInGE7eIegtrBeACg7GOt
gM0finkJL0tRmXm9685vS10=
=8M+k
-----END PGP SIGNATURE-----
