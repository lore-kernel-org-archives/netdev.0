From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] tg3: fix big endian MAC address collection failure
Date: Mon, 13 Apr 2009 20:56:55 -0700
Message-ID: <C27F8246C663564A84BB7AB343977242177D75A050@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <20090413.195159.56924183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "James.Bottomley@HansenPartnership.com"
	<James.Bottomley@HansenPartnership.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>
To: "'David Miller'" <davem@davemloft.net>,
	"Matthew Carlson" <mcarlson@broadcom.com>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <20090413.195159.56924183.davem@davemloft.net>
Content-Language: en-US
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> From: "Matt Carlson" <mcarlson@broadcom.com>
> Date: Mon, 13 Apr 2009 19:00:15 -0700
>
> > I did run some tests this afternoon on a similar IA64 HP machine and
> > they ran fine.
>
> It can't be similar, James Bottomly is on HP PARISC (big endian) not
> IA64 (which is little endian).

Matt brought up IA64 because Robin Holt reported what seemed like an
identical issue on SGI IA64 machine.

>
> I'm still convinced this is a big-endian driver problem and it has
> nothing to do with broken NVRAM or similar.
>
>

Agreed.  James' problem appears to be a big endian issue.  Everything
is endian-swapped in his NVRAM when he did the ethtool dump.

