From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Ipsec-tools-devel] Re: [PATCH 2.6]: Check against correct policy
 list in ip_forward/ip6_forward
Date: Tue, 19 Oct 2004 17:38:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417534F1.1010401@trash.net>
References: <4172943B.8050904@trash.net> <20041017212317.GA28615@gondor.apana.org.au> <4172F1AB.4020305@trash.net> <20041017231258.GA29294@gondor.apana.org.au> <4175334B.3000504@gmc.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, ipsec-tools-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Aidas Kasparas <a.kasparas@gmc.lt>
In-Reply-To: <4175334B.3000504@gmc.lt>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Aidas Kasparas wrote:

> I'm sorry, what is wrong with racoon?

When generate_policy is set to on racoon doesn't generate forward
policies for tunnel mode SAs, so traffic forwarded from a tunnel
is not subject to policy checks.

I have a patch which fixes this, I will post it a couple of days.

Regards
Patrick
