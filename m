From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] netlink oops fix due to incorrect error code
Date: Mon, 09 Jan 2006 15:54:53 -0800 (PST)
Message-ID: <20060109.155453.02785248.davem@davemloft.net>
References: <43C27662.2030400@openvz.org>
	<43C2F6DC.7040602@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dev@openvz.org, torvalds@osdl.org, akpm@osdl.org,
	linux-kernel@vger.kernel.org, dim@sw.ru, st@sw.ru,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751659AbWAIX7Y@vger.kernel.org>
To: kaber@trash.net
In-Reply-To: <43C2F6DC.7040602@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 10 Jan 2006 00:50:52 +0100

> Kirill Korotaev wrote:
> > Fixed oops after failed netlink socket creation.
> > Wrong parathenses in if() statement caused err to be 1,
> > instead of negative value.
> > Trivial fix, not trivial to find though.
> > 
> > Signed-Off-By: Dmitry Mishin <dim@sw.ru>
> > Signed-Off-By: Kirill Korotaev <dev@openvz.org>
> 
> Good catch. Dave, please apply.

Already in Linus's tree, he applied it directly :-)
