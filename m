From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC PATCH net-next] tcp: introduce tcp_tw_interval to specifiy
 the time of TIME-WAIT
Date: Thu, 27 Sep 2012 10:02:22 -0700
Message-ID: <5064869E.9060503@hp.com>
References: <1348735261-29225-1-git-send-email-amwang@redhat.com> <20120927142334.GA3194@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:23874 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753011Ab2I0RC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 13:02:28 -0400
In-Reply-To: <20120927142334.GA3194@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/27/2012 07:23 AM, Neil Horman wrote:
> The code looks fine, but the idea really doesn't seem like a good plan to me.
> I'm sure HPUX/Solaris/AIX/etc have done this in response to customer demand, but
> that doesn't make it the right solution.

In the case of HP-UX at least, while the rope is indeed there, the 
advice is to not wrap it around one's neck unless one *really* has a 
handle on the environment.  Instead things suggested, in no particular 
order:

*) The aforementioned SO_REUSEADDR to address the "I can't restart the 
server quickly enough." issue

*) Tuning the size of the anonymous/ephemeral port range.

*) Making explicit bind() calls using the entire non-privileged port range

*) Making the connections longer-lived.  Especially if the comms are 
between a fixed set of IP addresses.

rick jones
