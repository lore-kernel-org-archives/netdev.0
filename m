From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: Use-after-free oops in next-20150204 - probably nelink related
Date: Sat, 21 Feb 2015 18:13:13 +0100
Message-ID: <54E8BCA9.4080603@iogearbox.net>
References: <AM3PR05MB0935A7C27C0F9D9BCD5B70E5DC2B0@AM3PR05MB0935.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Shachar Raindel <raindel@mellanox.com>, Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AM3PR05MB0935A7C27C0F9D9BCD5B70E5DC2B0@AM3PR05MB0935.eurprd05.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/21/2015 04:36 PM, Shachar Raindel wrote:
...
>> This is most likely rhashtable related. The fixes for the
>> use-after-free issues have been merged Feb 6 so they are probably
>> not included in the Feb 04 snapshot that you use.
>>
>> The relevant net-next commits are:
>> commit 020219a69d40a205dad12b0ea1e6a46153793368
>> commit cf52d52f9ccb9966ac019d9f79824195583e3e6c
>> commit 2af4b52988fd4f7ae525fcada29d4db8680033d6
>> commit a5ec68e3b8f2c95ea1a5d23dd543abbe0c8d0624
>
> Most likely so - haven't seen this reproducing so far on next-20150219,
> which contains the relevant commits.

Thanks for double checking!

> BTW, why is there no MAINTAINERS entry for the netlink subsystem?

Well, if in doubt where to send a bug report, then :

   scripts/get_maintainer.pl -f net/netlink/

Make sure to Cc netdev in any case.
