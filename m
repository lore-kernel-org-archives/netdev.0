From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Kconfig Dependencies for CONFIG_NET_CLS_RSVP6
Date: Thu, 13 Oct 2005 23:59:07 -0700 (PDT)
Message-ID: <20051013.235907.66789139.davem@davemloft.net>
References: <434F5247.2040007@tuxrocks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750864AbVJNG7T@vger.kernel.org>
To: frank@tuxrocks.com
In-Reply-To: <434F5247.2040007@tuxrocks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frank Sorenson <frank@tuxrocks.com>
Date: Fri, 14 Oct 2005 00:37:59 -0600

> I noticed that I can still select "Special RSVP classifier for IPv6"
> even if "The IPv6 protocol" isn't selected.  Should CONFIG_NET_CLS_RSVP6
> depend on or select IPV6?
> 
> Currently:
> Depends on: NET && NET_CLS && NET_QOS

It doesn't need the ipv6 stack at all, it's just a classifier
that looks at packet headers and makes decisions.
