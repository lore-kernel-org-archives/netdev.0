From: Aidas Kasparas <a.kasparas@gmc.lt>
Subject: Re: [Ipsec-tools-devel] Re: [PATCH 2.6]: Check against correct policy
 list in ip_forward/ip6_forward
Date: Tue, 19 Oct 2004 18:57:19 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4175395F.9050409@gmc.lt>
References: <4172943B.8050904@trash.net> <20041017212317.GA28615@gondor.apana.org.au> <4172F1AB.4020305@trash.net> <20041017231258.GA29294@gondor.apana.org.au> <4175334B.3000504@gmc.lt> <417534F1.1010401@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, ipsec-tools-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <417534F1.1010401@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Patrick McHardy wrote:
> Aidas Kasparas wrote:
> 
>> I'm sorry, what is wrong with racoon?
> 
> 
> When generate_policy is set to on racoon doesn't generate forward
> policies for tunnel mode SAs, so traffic forwarded from a tunnel
> is not subject to policy checks.

Patrick,

	what _forward_ policies should racoon generate. And WHY?!

Could you please specify for the case when:
- remote host has address A.A.A.A
- security gateway have insecure adress B.B.B.B
- secured network is C.C.C.0/24, security gateway's address C.C.C.C

what policies in your oppinion has to be inserted into SPD for this 
setup by racoon?

	Thanks in advance.

> 
> I have a patch which fixes this, I will post it a couple of days.
> 
> Regards
> Patrick
> 

-- 
Aidas Kasparas
IT administrator
GM Consult Group, UAB
