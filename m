From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: gone with the spring cleanup..
Date: Wed, 13 May 2015 13:26:34 +0200
Message-ID: <555334EA.4000404@iogearbox.net>
References: <5553158D.7000108@mellanox.com> <20150513103812.GA2136@nanopsycho.mtl.com> <20150513104249.GB2136@nanopsycho.mtl.com> <55532DBD.1080901@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Feldman <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <ogerlitz@mellanox.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59173 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754506AbbEML0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 07:26:42 -0400
In-Reply-To: <55532DBD.1080901@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/13/2015 12:55 PM, Or Gerlitz wrote:
> On 5/13/2015 1:42 PM, Jiri Pirko wrote:
>>> Looks like the problem might be in named structures which suppose to be
>>> >anonymous. Would you try following patch:
>> oh, switchdev_obj_vlan and switchdev_obj_ipv4_fib is used in rocker..
>> So better:
>
> nope, fails.. if I remove the union (it is struct switchdev_obj has strict vlan and ipv4_fib fields) it works. Seems there's some problem also with anonymous unions.

Yes, we once had such an issue here btw:

https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/lib/test_bpf.c?id=ece80490e2c1cefda018b2e5b96d4f39083d9096
