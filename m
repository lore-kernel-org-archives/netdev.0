From: Shachar Raindel <raindel@mellanox.com>
Subject: RE: Use-after-free oops in next-20150204 - probably nelink related
Date: Sat, 21 Feb 2015 15:36:11 +0000
Message-ID: <AM3PR05MB0935A7C27C0F9D9BCD5B70E5DC2B0@AM3PR05MB0935.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> -----Original Message-----
> From: Thomas Graf [mailto:tgr@infradead.org] On Behalf Of Thomas Graf
> Sent: Thursday, February 19, 2015 5:49 PM
> To: Shachar Raindel
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: Use-after-free oops in next-20150204 - probably nelink
> related
> 
> On 02/18/15 at 03:52pm, Shachar Raindel wrote:
> > Hi,
> >
> > I'm running trinity inside a VM running linux-next tagged next-
> 20150204.
> >
> > The kernel debugging infrastructure detected a use-after-free
> situation, probably in netlink:
> 
> This is most likely rhashtable related. The fixes for the
> use-after-free issues have been merged Feb 6 so they are probably
> not included in the Feb 04 snapshot that you use.
> 
> The relevant net-next commits are:
> commit 020219a69d40a205dad12b0ea1e6a46153793368
> commit cf52d52f9ccb9966ac019d9f79824195583e3e6c
> commit 2af4b52988fd4f7ae525fcada29d4db8680033d6
> commit a5ec68e3b8f2c95ea1a5d23dd543abbe0c8d0624

Most likely so - haven't seen this reproducing so far on next-20150219,
which contains the relevant commits.

Thanks for pointing this out.

BTW, why is there no MAINTAINERS entry for the netlink subsystem?

Thanks,
--Shachar
