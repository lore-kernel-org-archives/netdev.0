From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch 3/4] Network namespaces: IPv4 FIB/routing in namespaces
Date: Wed, 28 Jun 2006 15:51:32 +0200
Message-ID: <44A28964.2090006@fr.ibm.com>
References: <20060626134945.A28942@castle.nmd.msu.ru> <20060626135250.B28942@castle.nmd.msu.ru> <20060626135427.C28942@castle.nmd.msu.ru> <449FF5AE.2040201@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrey Savochkin <saw@swsoft.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, serue@us.ibm.com, haveblue@us.ibm.com,
	clg@fr.ibm.com, Andrew Morton <akpm@osdl.org>, dev@sw.ru,
	herbert@13thfloor.at, devel@openvz.org, sam@vilain.net,
	ebiederm@xmission.com, viro@ftp.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:11702 "EHLO
	mtagate4.de.ibm.com") by vger.kernel.org with ESMTP
	id S1423337AbWF1OH4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 10:07:56 -0400
To: Daniel Lezcano <dlezcano@fr.ibm.com>
In-Reply-To: <449FF5AE.2040201@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Lezcano wrote:
> Andrey Savochkin wrote:
> 
>> Structures related to IPv4 rounting (FIB and routing cache)
>> are made per-namespace.

Hi Andrey,

if the ressources are private to the namespace, how do you will handle 
NFS mounted before creating the network namespace ? Do you take care of 
that or simply assume you can't access NFS anymore ?

Regards

  -Daniel
