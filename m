From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [RFC] netem: correlated loss generation (v3)
Date: Wed, 19 May 2010 23:42:39 +0200
Message-ID: <20100519214239.GD5146@nuttenaction>
References: <4BD84428.30904@uniroma2.it>
 <20100517205621.036a06e0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefano Salsano <stefano.salsano@uniroma2.it>,
	David Miller <davem@davemloft.net>,
	Fabio Ludovici <fabio.ludovici@yahoo.it>,
	netdev@vger.kernel.org, netem@lists.linuxfoundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:34293 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751085Ab0ESVuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 17:50:09 -0400
Content-Disposition: inline
In-Reply-To: <20100517205621.036a06e0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Stephen Hemminger | 2010-05-17 20:56:21 [-0700]:

>Subject: netem - revised correlated loss generator
>
>This is a patch originated with Stefano Salsano and Fabio Ludovici.
>It provides several alternative loss models for use with netem.
>There are two state machine based models and one table driven model.
>
>To simplify the original code:
>   * eliminated the debugging messages and statistics
>   * reformatted for clarity
>   * changed API to nested attribute relating to loss
>   * changed the table to always loop across bits
>   * only allocate parameters needed
>
>Still untested, for comment only...
>Should have tested version before 2.6.35 merge window closes.

Why mainline? I questioning the advantage for the big audience, it looks like
a academic only piece of software - correct me if I'm wrong.

The authors pointed to some weak points in the implementation of the current
loss/correlation logic. But this "fix", add another - complicated component -
and let the broken components untouched ...

HGN

-- 
Hagen Paul Pfeifer <hagen@jauu.net>  ||  http://jauu.net/
Telephone: +49 174 5455209           ||  Key Id: 0x98350C22
Key Fingerprint: 490F 557B 6C48 6D7E 5706 2EA2 4A22 8D45 9835 0C22
