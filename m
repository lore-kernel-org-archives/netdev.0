From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [PATCH] Check if user has CAP_NET_ADMIN to change congestion control algorithm
Date: Fri, 27 Oct 2006 12:59:30 +1300
Message-ID: <5640c7e00610261659g5816942ndaf4e09eb8110c9e@mail.gmail.com>
References: <20061025110843.0cbd18a7@freekitty> <4540F076.70801@psc.edu>
	 <20061026224407.GA2018@c3po.0xdef.net>
	 <20061026235256.GB2018@c3po.0xdef.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:16830 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1946036AbWJZX7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 19:59:32 -0400
Received: by ug-out-1314.google.com with SMTP id 32so543671ugm
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2006 16:59:31 -0700 (PDT)
To: "Hagen Paul Pfeifer" <hagen@jauu.net>,
	"John Heffner" <jheffner@psc.edu>,
	"Stephen Hemminger" <shemminger@osdl.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
In-Reply-To: <20061026235256.GB2018@c3po.0xdef.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/27/06, Hagen Paul Pfeifer <hagen@jauu.net> wrote:
>
> Check if user has CAP_NET_ADMIN capability to change congestion control
> algorithm.
>
> Under normal circumstances a application programmer doesn't have enough
> information to choose the "right" algorithm (expect he is the pchar/pathchar
> maintainer). At 99.9% only the local host administrator has the knowledge to
> select a proper standard, system-wide algorithm (the remaining 0.1% are
> for testing purpose). If we let the user select an alternative algorithm we
> introduce one potential weak spot - so we ban this eventuality.
>
I don't agree with this at all. I would love Firefox, BitTorrent etc
to implement usage of TCP-LP for example so they use "unused"
bandwidth only.

With this change applications can't do this.

If we are going to restrict by capabilities then I think we should
only restrict module loading - this way the admin of the box can
decide what algorithms can be used.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
