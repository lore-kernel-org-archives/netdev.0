From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v5] net: ipv6: Make address flushing on ifdown
 optional
Date: Wed, 14 Oct 2015 13:03:41 +0200
Message-ID: <1444820621.2175377.409880265.37A31E2D@webmail.messagingengine.com>
References: <1444667587-13863-1-git-send-email-dsa@cumulusnetworks.com>
 <20151013.184539.1401344867685512636.davem@davemloft.net>
 <1444815241.2154853.409816321.48710CD1@webmail.messagingengine.com>
 <561E29A3.9080101@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hannes@redhat.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Miller <davem@davemloft.net>, dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:39781 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751990AbbJNLDm convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 07:03:42 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 84AAE2065C
	for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 07:03:41 -0400 (EDT)
In-Reply-To: <561E29A3.9080101@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2015, at 12:08, Nicolas Dichtel wrote:
> Le 14/10/2015 11:34, Hannes Frederic Sowa a =C3=A9crit :
> [sni]
> > This sysctl is on my list to be enabled soon by default by any syst=
emd
> > based distribution. For that reason, could you maybe remove all the
> I'm not sure to understand why we add a sysctl then. Or at least, why=
 the
> linux
> default value is different from all standard distrib. I will be like
> rp_filter :/

The difference is that people upgrade (in case of fedora they get a
=2Erpmnew file) or install a distribution and don't wonder or have
assumptions about old behavior. In case companies integrate kernel in
products/appliances without a way to manage those sysctls we cannot
simply change them as this would break assumptions for them. I think
those are two different cases.

Bye,
Hannes
