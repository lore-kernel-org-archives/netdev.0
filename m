From: kuznet@ms2.inr.ac.ru
Subject: Re: Mail delivery failed: returning message to sender
Date: Wed, 21 May 2003 06:22:10 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200305210222.GAA13659@dub.inr.ac.ru>
References: <20030520.175553.35669773.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rmk@arm.linux.org.uk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20030520.175553.35669773.davem@redhat.com> from "David S. Miller" at May 20, 2003 05:55:53 PM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> I STRONGLY suspect the *rt = *rth assignment in
> route.c:ip_rt_redirect().  In particular this results in
> rt->u.dst.path pointing to the old &rth->u.dst, oops.

Oops, indeed.

> Russel, please retest using this patch.  This piece of
> code needs to be audited further.

Relax, it is right now.

I hope it is the only place where route is copied as whole.

Alexey
