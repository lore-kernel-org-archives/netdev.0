From: Jan Engelhardt <jengelh@medozas.de>
Subject: RE: [v4 PATCH 2/2] NETFILTER userspace part for target HMARK
Date: Fri, 25 Nov 2011 16:44:07 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1111251638250.26014@frira.zrqbmnf.qr>
References: <1322213787-25796-1-git-send-email-hans@schillstrom.com> <1322213787-25796-3-git-send-email-hans@schillstrom.com>,<alpine.LNX.2.01.1111251418440.6279@frira.zrqbmnf.qr> <C8A6796DE7C66C4ABCBC18106CB6C1CC1641FB1D64@ESESSCMS0356.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hans Schillstrom <hans@schillstrom.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?Q?Hans_Schillstr=C3=B6m?= <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <C8A6796DE7C66C4ABCBC18106CB6C1CC1641FB1D64@ESESSCMS0356.eemea.ericsson.se>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 2011-11-25 15:04, Hans Schillstr=C3=B6m wrote:

>
>>On Friday 2011-11-25 10:36, Hans Schillstrom wrote:
>>
>>>+Parameters:
>>>+For all masks default is all "1:s", to disable a field use mask 0
>>>+For IPv6 it's just the last 32 bits that is included in the hash
>>
>>Why limit IPv6 to 32?
>
>Performance, and the gain of adding another 192 bits to jhash ain't mu=
ch.
>However there is some cases when it hurts, i.e. when you can't mask of=
 an subnet
>I'm not sure it it's a problem or not...=20

I was thinking about the case where two particular hosts have the same=20
trailing 32 bits in their source address. For example, assuming IPv6=20
starts to take a stronghold in the real world and home customers start=20
assigning <myprefix>::1 to the little home server (i.e. the PPP=20
endpoint) of theirs for remote login.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
