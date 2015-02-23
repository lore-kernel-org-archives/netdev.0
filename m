From: niyas mydeen <aniyas15@gmail.com>
Subject: GARP Issue
Date: Mon, 23 Feb 2015 12:32:59 +0530
Message-ID: <CADoAD8JGniD=cbRBP9Esi1V4GfUhQCsWqgurnmVgSwhT_qAXZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Ian Campbell <ian.campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

I am working custom platform based on x86_64 running 3.10 kernel,
Recently I found an issue related to GARP. It seems like  no GARP
packets are being sent out when an Interface is made up. But I also
noticed that only when I use "arping" tool only then it sends out any
GARP packet.

I also try setting the net variable "arp_notify" then I see the
arp_send() function is being called after that I am unable to track
further.

Could you please help me, what could be issue, Is it a valid
expectation that during interface up the linux kernel should send out
GARP packet? If so, am I missing any kernel configuration related to
it?

Thanks in Advance.

Regards,
A.Mydeen.
