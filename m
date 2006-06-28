From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Network namespaces a path to mergable code.
Date: Wed, 28 Jun 2006 08:56:26 -0600
Message-ID: <m1irmlgwh1.fsf@ebiederm.dsl.xmission.com>
References: <20060626134945.A28942@castle.nmd.msu.ru>
	<m14py6ldlj.fsf@ebiederm.dsl.xmission.com>
	<20060627215859.A20679@castle.nmd.msu.ru>
	<44A1AF37.3070100@vilain.net>
	<m1ac7xkifn.fsf@ebiederm.dsl.xmission.com>
	<44A21F7A.5030807@vilain.net>
	<m1r719ixb6.fsf@ebiederm.dsl.xmission.com> <44A251F2.70707@fr.ibm.com>
	<m1bqsdidhe.fsf@ebiederm.dsl.xmission.com>
	<20060628141539.GA32736@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cedric Le Goater <clg@fr.ibm.com>, Sam Vilain <sam@vilain.net>,
	Andrey Savochkin <saw@swsoft.com>, dlezcano@fr.ibm.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	haveblue@us.ibm.com, Andrew Morton <akpm@osdl.org>, dev@sw.ru,
	herbert@13thfloor.at, devel@openvz.org, viro@ftp.linux.org.uk,
	Alexey Kuznetsov <alexey@sw.ru>,
	Mark Huang <mlhuang@CS.Princeton.EDU>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:38378 "EHLO
	ebiederm.dsl.xmission.com") by vger.kernel.org with ESMTP
	id S932285AbWF1O5q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 10:57:46 -0400
To: "Serge E. Hallyn" <serue@us.ibm.com>
In-Reply-To: <20060628141539.GA32736@sergelap.austin.ibm.com> (Serge
	E. Hallyn's message of "Wed, 28 Jun 2006 09:15:39 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Serge E. Hallyn" <serue@us.ibm.com> writes:

> Quoting Eric W. Biederman (ebiederm@xmission.com):
>> > I think we're reaching the limits of namespaces. It would be much easier
>> > with a container id in each kernel object we want to isolate.
>> 
>> Nope.  Except for the fact that names are peculiar (sockets, network
>> device names, IP address, routes...) the network stack splits quite cleanly.
>> 
>> I did all of this in a proof of concept mode several months ago and
>> the code is still sitting in my git tree on kernel.org.  I even got
>> the generic stack reference counting fixed.
>> 
>> Eric
>
> Which branch?

It should be the proof-of-concept branch.  It is a development branch so the
history is ugly but the result was fairly decent.

Eric
