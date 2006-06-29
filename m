From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: Network namespaces a path to mergable code.
Date: Thu, 29 Jun 2006 11:42:37 +0200
Message-ID: <44A3A08D.6060502@fr.ibm.com>
References: <20060626134945.A28942@castle.nmd.msu.ru>	<m14py6ldlj.fsf@ebiederm.dsl.xmission.com>	<20060627215859.A20679@castle.nmd.msu.ru>	<m1ejx9kj1r.fsf@ebiederm.dsl.xmission.com>	<20060628150605.A29274@castle.nmd.msu.ru>	<44A2FA66.5070303@fr.ibm.com> <m11wt8erjv.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrey Savochkin <saw@swsoft.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, serue@us.ibm.com, haveblue@us.ibm.com,
	clg@fr.ibm.com, Andrew Morton <akpm@osdl.org>, dev@sw.ru,
	herbert@13thfloor.at, devel@openvz.org, sam@vilain.net,
	viro@ftp.linux.org.uk, Alexey Kuznetsov <alexey@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:14171 "EHLO
	mtagate1.uk.ibm.com") by vger.kernel.org with ESMTP id S932873AbWF2Jmt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 05:42:49 -0400
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m11wt8erjv.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
>>When an outgoing packet has the loopback destination addres, the
>>skbuff is filled with the network namespace. So the loopback packets
>>never go outside the namespace. This approach facilitate the migration
>>of loopback because identification is done by network namespace and
>>not by address. The loopback has been benchmarked by tbench and the
>>overhead is roughly 1.5 %
> 
> 
> Ugh.  1.5% is noticeable.

We will see with all private network namespace ...
> 
> I think it is cheaper to have one loopback device per namespace.
> Which removes the need for a skbuff tag.

Yes, probably.
