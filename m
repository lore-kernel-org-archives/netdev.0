From: Andre Uratsuka Manoel <andreum@gmail.com>
Subject: route cache overflow
Date: Tue, 6 Jul 2004 00:33:15 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <e7fcadd304070520335b493747@mail.gmail.com>
Reply-To: andre@insite.com.br
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

It seems that no resolution was found for the route cache DoS issue
(am I wrong here?).

I was wondering, and I'd like to persue this line of thought if you
don't consider this stupid: wouldn't it be better, when we find that
the machine is under DoS to avoid creating route cache entries instead
of simply trying to drop entries that exist?

Couldn't we create entries only once for every 1<<n packets on
ip_route_input_slow so that flows with many packets will have route
cache entries created with higher probability than flows with very
little connections. The n variable could be adjusted according to
perceived DoS-ness.

Is this stupid?

Andre
