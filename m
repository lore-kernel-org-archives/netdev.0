From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] repairing rtcache killer
Date: Wed, 6 Aug 2003 21:58:09 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308061758.VAA01743@dub.inr.ac.ru>
References: <16177.13435.45921.229742@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, Robert.Olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert.Olsson@data.slu.se (Robert Olsson)
In-Reply-To: <16177.13435.45921.229742@robur.slu.se> from "Robert Olsson" at Aug 06, 2003 07:01:47 PM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

>  Crap. We are back to the dst cache overflow again even with routing tables 
>  loaded. Well test is now on SMP and 2.6.0-test1. Undo the min_score test 
>  and give it retry?

No. This patch is not related to RCU problem at all. It just sanitizes
craziness of balancing introduced by chain truncation,
that's why the subject is different. :-)

I think you did not apply patch, which is responsible for repairing
rcu troubles.

Alexey
