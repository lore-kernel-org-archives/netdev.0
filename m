From: kuznet@ms2.inr.ac.ru
Subject: Re: Fw: [PATCH] set NLM_F_MULTI in answer of RTM_GETADDR dump answer
Date: Sun, 10 Aug 2003 07:03:48 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308100303.HAA20709@dub.inr.ac.ru>
References: <20030809011153.46a99ef2.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20030809011153.46a99ef2.davem@redhat.com> from "David S. Miller" at Aug 09, 2003 01:11:53 AM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> After sending RTM_GETADDR dump request to netlink socket, received multipart
> answer does not have NLM_F_MULTI set on each message. This patch fix that.

OK.

Actually, this flag was never used because of its redundancy
it is not the only place where it is not set.

Alexey
