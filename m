From: Alex Sidorenko <alexandre.sidorenko@hp.com>
Subject: Re: An inconsistency/bug in ingress netem timestamps
Date: Wed, 15 Apr 2009 17:00:59 -0400
Message-ID: <200904151700.59906.alexandre.sidorenko@hp.com>
References: <20090415195022.GA3322@ami.dom.local> <20090415202620.GB3322@ami.dom.local> <20090415132918.7579ffa6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:33485 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753374AbZDOVBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 17:01:03 -0400
In-Reply-To: <20090415132918.7579ffa6@nehalam>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On April 15, 2009 04:29:18 pm Stephen Hemminger wrote:
>  As long as it is consistent, then I have no problem
> with the existing behavior; ie. it is not a bug, it just works that way.

Hi Stephen,

the timestamps change depending on whether there are any ptype_all handlers 
registered. Just starting tcpdump changes the behaviour, this probably 
means 'inconsistent' ?

Regards,
Alex

-- 
------------------------------------------------------------------
Alexandre Sidorenko             email: asid@hp.com
WTEC Linux			Hewlett-Packard (Canada)
------------------------------------------------------------------
