From: Ricky Beam <jfbeam@bluetronic.net>
Subject: Re: /proc/net/* read drops data
Date: Thu, 4 Sep 2003 12:25:16 -0400 (EDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.GSO.4.33.0309041223430.13584-100000@sweetums.bluetronic.net>
References: <20030904004638.1d4b001d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>,
	<linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030904004638.1d4b001d.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Thu, 4 Sep 2003, David S. Miller wrote:
>> D: Fixing a bug that reading /proc/net/{udp,udp6} may drop some data
>
>This fix looks good to me.  Applied.

The list:
(file)			(bs=1)	(bs=10000)
/proc/net/igmp		122     191
/proc/net/route		128     384
/proc/net/rt_acct	0	4096
/proc/net/rt_cache	384     512
/proc/net/tcp		1800    1950
/proc/net/udp		1024    1152

(I don't have ipv6 enabled)

--Ricky
