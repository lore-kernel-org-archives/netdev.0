From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Sat, 28 Sep 2002 06:28:29 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209280228.GAA02633@sex.inr.ac.ru>
References: <20020927.182833.66704359.davem@redhat.com>
Mime-Version: 1.0
Cc: yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20020927.182833.66704359.davem@redhat.com> from "David S. Miller" at Sep 27, 2 06:28:33 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Otherwise I have no problems with the patch, Alexey?

I have... The implementation is bad. Source address must be retieved
from route, not running this elephant function each packet.

Alexey
