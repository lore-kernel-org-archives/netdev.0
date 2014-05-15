From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: Collecting data to demonstrate TCP ISN-based port knocking
Date: Thu, 15 May 2014 10:23:50 +0200
Message-ID: <20140515082350.GC5287@cpaasch-mac>
References: <e322ab1d41b74aa093af558cf3f081f4@UCL-MBX03.OASIS.UCLOUVAIN.BE>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Christian Grothoff <christian@grothoff.org>
To: Julian Kirsch <kirschju@sec.in.tum.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <e322ab1d41b74aa093af558cf3f081f4@UCL-MBX03.OASIS.UCLOUVAIN.BE>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 14/05/14 - 21:55:36, Julian Kirsch wrote:
> some of you might remember the proposal of a patch which implements a
> variant of port-knocking that can be used to check the authenticity of
> arbitrary TCP connections and even can do integrity checking of TCP
> payload data by using a pre-shared key [0]. This patch, as well as a
> research paper describing its inner workings are available on
> gnunet.org under the name "Knock" [1].
> 
> As Knock uses two fields in the TCP header in order to hide
> information and we explicitly want to be compatible with machines
> sitting in typical home networks, we need to make sure that this
> information doesn't get corrupted by the majority of NAT boxes out
> there. The lack of hard data on this also was one of the objections
> when the patch was submitted last time. We thus created a program
> which tests if Knock could work in your environment. It would be
> greatly appreciated if some of you were able to execute the program on
> their machines in order to help us to get an estimation of if Knock
> one day could be used in a large scale.

have you looked at
http://www.eecs.berkeley.edu/~sylvia/cs268-2014/papers/deploytcp-imc11.pdf ?

Michio started a second larger measurement campaign 2 years ago. You might ask
him if he has more data now.


Cheers,
Christoph
