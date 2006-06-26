From: Herbert Poetzl <herbert@13thfloor.at>
Subject: Re: [patch 3/4] Network namespaces: IPv4 FIB/routing in namespaces
Date: Mon, 26 Jun 2006 22:05:14 +0200
Message-ID: <20060626200513.GB5330@MAIL.13thfloor.at>
References: <20060626134945.A28942@castle.nmd.msu.ru> <20060626135250.B28942@castle.nmd.msu.ru> <20060626135427.C28942@castle.nmd.msu.ru> <449FF5AE.2040201@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrey Savochkin <saw@swsoft.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, serue@us.ibm.com, haveblue@us.ibm.com,
	clg@fr.ibm.com, Andrew Morton <akpm@osdl.org>, dev@sw.ru,
	devel@openvz.org, sam@vilain.net, ebiederm@xmission.com,
	viro@ftp.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from MAIL.13thfloor.at ([212.16.62.50]:61142 "EHLO mail.13thfloor.at")
	by vger.kernel.org with ESMTP id S932994AbWFZUFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 16:05:15 -0400
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Content-Disposition: inline
In-Reply-To: <449FF5AE.2040201@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 26, 2006 at 04:56:46PM +0200, Daniel Lezcano wrote:
> Andrey Savochkin wrote:
> >Structures related to IPv4 rounting (FIB and routing cache)
> >are made per-namespace.
> 
> How do you handle ICMP_REDIRECT ?

and btw. how do you handle the beloved 'ping'
(i.e. ICMP_ECHO_REQUEST/REPLY for and from
guests?

best,
Herbert

