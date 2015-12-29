From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: Q: bad routing table cache entries
Date: Tue, 29 Dec 2015 06:58:21 -0500
Message-ID: <20151229115821.GA9352@oracle.com>
References: <5682665A.7090102@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40428 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753073AbbL2L6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 06:58:33 -0500
Content-Disposition: inline
In-Reply-To: <5682665A.7090102@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (12/29/15 13:54), Stas Sergeev wrote:
> 
> ip route get 91.189.89.238
> 91.189.89.238 via 192.168.0.1 dev eth0  src 192.168.10.202
>     cache <redirected>
         :
> Now, 192.168.0.1 is also a valid gateway, but it is outside
> of the network mask for the eth0 interface:
         :
> So my question is: why does linux allow an invalid redirect
> entries? Is it a problem with my setup, or some kernel bug,
> or some router setup problem? Where should I look into, to
> nail this down?

Seems like the problem is in the router that is sending
the bad redirect. You would have to check into the configuration
and/or implementation of the router- it should not be sending
back a redirect in the above case (different netmasks) even
if the ingress and egress physical interfaces are the same.

--Sowmini
