From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [Devel] Re: [RFC] network namespaces
Date: Mon, 11 Sep 2006 17:04:38 +0200
Message-ID: <45057B06.8060902@fr.ibm.com>
References: <20060815182029.A1685@castle.nmd.msu.ru> <200609081710.09124.dim@openvz.org> <20060908181154.GA8745@MAIL.13thfloor.at> <200609091157.24734.dim@openvz.org> <4505757B.3020004@fr.ibm.com> <20060911145724.GB27223@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dmitry Mishin <dim@openvz.org>, Kir Kolyshkin <kir@openvz.org>,
	Andrey Savochkin <saw@sw.ru>, netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>, alexey@sw.ru,
	sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:24458 "EHLO
	mtagate2.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1751193AbWIKPEj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Sep 2006 11:04:39 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.8/8.13.8) with ESMTP id k8BF4cpR164606
	for <netdev@vger.kernel.org>; Mon, 11 Sep 2006 15:04:38 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8BF6lbR1232994
	for <netdev@vger.kernel.org>; Mon, 11 Sep 2006 16:06:47 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8BF4bFY015477
	for <netdev@vger.kernel.org>; Mon, 11 Sep 2006 16:04:38 +0100
To: Herbert Poetzl <herbert@13thfloor.at>
In-Reply-To: <20060911145724.GB27223@MAIL.13thfloor.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Poetzl wrote:
> On Mon, Sep 11, 2006 at 04:40:59PM +0200, Daniel Lezcano wrote:
> 

>>I am currently working on this and I am finishing a prototype bringing
>>isolation at the ip layer. The prototype code is very closed to
>>Andrey's patches at TCP/UDP level. So the next step is to merge the
>>prototype code with the existing network namespace layer 2 isolation.
> 
> 
> you might want to take a look at the current Linux-VServer
> implementation for the network isolation too, should be
> quite similar to Andrey's approach, but maybe you can
> gather some additional information from there

ok, thanks. I will.

>>IHMO, the solution of spliting CONFIG_NET_NS into CONFIG_L2_NET_NS
>>and CONFIG_L3_NET_NS is for me not acceptable because you will need
>>to recompile the kernel. The proper way is certainly to have a
>>specific flag for the unshare, something like CLONE_NEW_L2_NET and
>>CLONE_NEW_L3_NET for example.
> 
> 
> I completely agree here, we need a separate namespace
> for that, so that we can combine isolation and virtualization
> as needed, unless the bind restrictions can be completely
> expressed with an additional mangle or filter table (as
> was suggested)

What is the bind restriction ? Do you want to force binding to a 
specific source address ?

   -- Daniel
