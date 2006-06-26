From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch 3/4] Network namespaces: IPv4 FIB/routing in namespaces
Date: Mon, 26 Jun 2006 17:57:01 +0200
Message-ID: <44A003CD.9050204@fr.ibm.com>
References: <20060626134945.A28942@castle.nmd.msu.ru> <20060626135250.B28942@castle.nmd.msu.ru> <20060626135427.C28942@castle.nmd.msu.ru> <449FF5AE.2040201@fr.ibm.com> <20060626194625.E989@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serue@us.ibm.com, haveblue@us.ibm.com, clg@fr.ibm.com,
	Andrew Morton <akpm@osdl.org>, dev@sw.ru, herbert@13thfloor.at,
	devel@openvz.org, sam@vilain.net, ebiederm@xmission.com,
	viro@ftp.linux.org.uk, Alexey Kuznetsov <alexey@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:56750 "EHLO
	mtagate3.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1750729AbWFZP5H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 11:57:07 -0400
To: Andrey Savochkin <saw@swsoft.com>
In-Reply-To: <20060626194625.E989@castle.nmd.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrey Savochkin wrote:
> On Mon, Jun 26, 2006 at 04:56:46PM +0200, Daniel Lezcano wrote:
> 
>>Andrey Savochkin wrote:
>>
>>>Structures related to IPv4 rounting (FIB and routing cache)
>>>are made per-namespace.
>>
>>How do you handle ICMP_REDIRECT ?
> 
> 
> Are you talking about routing cache entries created on incoming redirects?
> Or outgoing redirects?
> 
> 	Andrey

incoming redirects
