From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [RFC] network namespaces
Date: Tue, 05 Sep 2006 17:32:01 +0200
Message-ID: <44FD9871.9090406@fr.ibm.com>
References: <20060815182029.A1685@castle.nmd.msu.ru>	<20060816115313.GC31810@sergelap.austin.ibm.com>	<44FD7CF0.4030009@fr.ibm.com> <m1ejuq2wz0.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Serge E. Hallyn" <serue@us.ibm.com>,
	Andrey Savochkin <saw@sw.ru>, haveblue@us.ibm.com,
	clg@fr.ibm.com, herbert@13thfloor.at, sam@vilain.net,
	Andrew Morton <akpm@osdl.org>, dev@sw.ru, devel@openvz.org,
	alexey@sw.ru, Linux Containers <containers@lists.osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:62124 "EHLO
	mtagate3.uk.ibm.com") by vger.kernel.org with ESMTP id S965125AbWIEPcD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Sep 2006 11:32:03 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.7/8.13.7) with ESMTP id k85FW2fY134256
	for <netdev@vger.kernel.org>; Tue, 5 Sep 2006 16:32:02 +0100
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k85FY7RM1532146
	for <netdev@vger.kernel.org>; Tue, 5 Sep 2006 16:34:07 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k85FW0IW026697
	for <netdev@vger.kernel.org>; Tue, 5 Sep 2006 16:32:01 +0100
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m1ejuq2wz0.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> For HPC if you are interested in migration you need a separate IP per
> container.  If you can take you IP address with you migration of
> networking state is simple.  If you can't take your IP address with
> you a network container is nearly pointless from a migration
> perspective.

Eric, please, I know... I showed you a migration demo at OLS ;)

> Beyond that from everything I have seen layer 2 is just much cleaner
> than any layer 3 approach short of Serge's bind filtering.

> Beyond that I have yet to see a clean semantics for anything
> resembling your layer 2 layer 3 hybrid approach.  If we can't have
> clear semantics it is by definition impossible to implement correctly
> because no one understands what it is supposed to do.

> Note.  A true layer 3 approach has no impact on TCP/UDP filtering
> because it filters at bind time not at packet reception time.  Once
> you start inspecting packets I don't see what the gain is from not
> going all of the way to layer 2.

The bsdjail was just for information ...


	- Daniel

