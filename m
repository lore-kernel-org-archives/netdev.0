From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [RFC] netem: correlated loss generation (v3)
Date: Thu, 20 May 2010 02:43:30 +0200
Message-ID: <20100520004330.GF5146@nuttenaction>
References: <4BD84428.30904@uniroma2.it>
 <20100517205621.036a06e0@nehalam>
 <20100519214239.GD5146@nuttenaction>
 <4BF46B90.1000806@uniroma2.it>
 <20100519230433.GE5146@nuttenaction>
 <20100519171733.71c24539@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefano Salsano <stefano.salsano@uniroma2.it>,
	David Miller <davem@davemloft.net>,
	Fabio Ludovici <fabio.ludovici@yahoo.it>,
	netdev@vger.kernel.org, netem@lists.linuxfoundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:48263 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752854Ab0ETAnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 20:43:32 -0400
Content-Disposition: inline
In-Reply-To: <20100519171733.71c24539@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Stephen Hemminger | 2010-05-19 17:17:33 [-0700]:

>The old model was useful, but it really didn't do correlated loss.
>For legacy, the old syntax will go through the same code and generate
>the same result.

Is this really necessary? The right thing is to fix the broken behavior! If
the new patch provides this, great.  Imaging a network analysis for a PhD
dissertation based on a broken correlation algorithm - the whole results are
misleading and wrong. No one deserves this ... ;-)

If the current algorithm is broken then the mechanism must be fixed. Preserve
compatibility is counterproductive in this case.

>tc qdisc change dev eth0 root netem 
>      loss 2 10                              # compat syntax
>      loss random 2 10                       # same as above
>      loss deterministic file                # loss model based on bitmap
>      loss state p13 [p31 [p32 [p23 [p14]]]] # 4 state 
>      loss model  p [r [1-h [1-k]]]          # gilbert elliot model
>
>Any suggestions for better syntax are appreciated.

Not at the moment, looks clear and understandable.


Cheers, Hagen

-- 
Hagen Paul Pfeifer <hagen@jauu.net>  ||  http://jauu.net/
Telephone: +49 174 5455209           ||  Key Id: 0x98350C22
Key Fingerprint: 490F 557B 6C48 6D7E 5706 2EA2 4A22 8D45 9835 0C22

