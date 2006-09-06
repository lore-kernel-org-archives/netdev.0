From: Kir Kolyshkin <kir@openvz.org>
Subject: Re: [Devel] Re: [RFC] network namespaces
Date: Wed, 06 Sep 2006 21:37:36 +0400
Message-ID: <44FF0760.1040600@openvz.org>
References: <20060815182029.A1685@castle.nmd.msu.ru>	<20060816115313.GC31810@sergelap.austin.ibm.com>	<44FD7CF0.4030009@fr.ibm.com>	<m1ejuq2wz0.fsf@ebiederm.dsl.xmission.com>	<20060905165328.GA17317@MAIL.13thfloor.at>	<44FE907F.7090508@fr.ibm.com> <20060906165642.GA26202@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	sam@vilain.net, Andrey Savochkin <saw@sw.ru>, alexey@sw.ru,
	Linux Containers <containers@lists.osdl.org>,
	"Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [62.205.161.221] ([62.205.161.221]:54933 "EHLO kir.sacred.ru")
	by vger.kernel.org with ESMTP id S1751788AbWIFRgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 13:36:23 -0400
To: devel@openvz.org
In-Reply-To: <20060906165642.GA26202@MAIL.13thfloor.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Poetzl wrote:
> my point (until we have an implementation which clearly
> shows that performance is equal/better to isolation)
> is simply this:
>
>  of course, you can 'simulate' or 'construct' all the
>  isolation scenarios with kernel bridging and routing
>  and tricky injection/marking of packets, but, this
>  usually comes with an overhead ...
>   
Well, TANSTAAFL*, and pretty much everything comes with an overhead. 
Multitasking comes with the (scheduler, context switch, CPU cache, etc.) 
overhead -- is that the reason to abandon it? OpenVZ and Linux-VServer 
resource management also adds some overhead -- do we want to throw it away?

The question is not just "equal or better performance", the question is 
"what do we get and how much we pay for it".

Finally, as I understand both network isolation and network 
virtualization (both level2 and level3) can happily co-exist. We do have 
several filesystems in kernel. Let's have several network virtualization 
approaches, and let a user choose. Is that makes sense?


* -- http://en.wikipedia.org/wiki/TANSTAAFL
