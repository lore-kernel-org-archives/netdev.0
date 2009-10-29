From: Andreas Petlund <apetlund@simula.no>
Subject: Re: [PATCH 2/3] net: TCP thin linear timeouts
Date: Thu, 29 Oct 2009 14:50:48 +0100
Message-ID: <F7D530D6-304E-4B99-8143-9E197AF8D74E@simula.no>
References: <4AE72079.4030504@simula.no> <4AE7B887.6090806@gmail.com>
Mime-Version: 1.0 (Apple Message framework v1076)
Content-Type: text/plain; charset=us-ascii; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	shemminger@vyatta.com, ilpo.jarvinen@helsinki.fi,
	davem@davemloft.net
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward1.uio.no ([129.240.10.70]:51130 "EHLO
	mail-forward1.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753805AbZJ2NvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 09:51:01 -0400
Received: from exim by mail-out1.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1N3VP7-0000Jr-DT
	for netdev@vger.kernel.org; Thu, 29 Oct 2009 14:51:05 +0100
In-Reply-To: <4AE7B887.6090806@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Den 28. okt. 2009 kl. 04.20 skrev William Allen Simpson:

> Sorry to be too picky about the naming, but "rm_expb" really doesn't
> mean what is actually done.  Perhaps TCP_THIN_LINEAR_BACKOFF and
> sysctl_tcp_thin_linear_backoff?
>

I agree that the name should be changed. As it represents linear  
timeouts and does not back off exponentially, I suggest  
TCP_THIN_LINEAR_TIMEOUTS and sysctl_tcp_thin_linear_timeouts.

> Also, as debated on some other recent patches, shouldn't the global
> sysctl specify the default, and the per socket option specify the
> forced override?

The rationale behind the suggested model is to allow the modifications  
to be forced active in cases where the application that generates the  
thin stream is proprietary, legacy, or that the code for other reasons  
can not be modified (as is the case, for instance, for many game  
clients).
