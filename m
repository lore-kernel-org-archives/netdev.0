From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] X25: Add ITU-T facilites
Date: Thu, 20 Oct 2005 14:30:15 +0200
Message-ID: <200510201430.17160.arnd@arndb.de>
References: <1129513666.3747.50.camel@localhost.localdomain> <Pine.LNX.4.61.0510181144320.28065@chaos.analogic.com> <1129770654.3574.1154.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "linux-os (Dick Johnson)" <linux-os@analogic.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>,
	eis@baty.hanse.de, linux-x25@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-x25-owner@vger.kernel.org>
To: Andrew Hendry <ahendry@tusc.com.au>
In-Reply-To: <1129770654.3574.1154.camel@localhost.localdomain>
Content-Disposition: inline
Sender: linux-x25-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Dunnersdag 20 Oktober 2005 03:10, Andrew Hendry wrote:
> __u32 or unsigned int look to be the norm for other similar headers,
> whats the recommended type of types to be used?
> 
Use __{u,s}{32,16,8} for interfaces and {u,s}{64,32,16,8} internally,
if you care about the exact size, otherwise use unsigned int.
See also http://lwn.net/Articles/113367/

	Arnd <><
