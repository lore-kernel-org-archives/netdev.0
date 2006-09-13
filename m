From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] make ipv4 multicast packets only get delivered to sockets	that are joined to group
Date: Thu, 14 Sep 2006 00:20:29 +0400
Message-ID: <20060913202029.GA4666@ms2.inr.ac.ru>
References: <1158156835.15449.40.camel@dantu.rdu.redhat.com> <OF0C86B64A.DE64FE98-ON882571E8.004F57A7-882571E8.004FDDED@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@poochiereds.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751169AbWIMUVT@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OF0C86B64A.DE64FE98-ON882571E8.004F57A7-882571E8.004FDDED@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> IPv6 behaves the same way.

Actually, Linux IPv6 filters received multicasts, inet6_mc_check() does
this.

IPv4 does not. I remember that attempts to do this were made in the past
and failed, because some applications, related to multicast routing,
did expect to receive all the multicasts even though they did not join
any multicast addresses. So, it was left intact.

Alexey
