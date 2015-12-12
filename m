From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: Checksum offload queries
Date: Sat, 12 Dec 2015 11:41:37 -0500
Message-ID: <20151212164137.GG19608@oracle.com>
References: <5665A848.9010001@solarflare.com>
 <20151207.143848.2158761076110518741.davem@davemloft.net>
 <5666EC4B.40800@solarflare.com>
 <20151208.120654.2127200076257822677.davem@davemloft.net>
 <56681B18.3030200@solarflare.com>
 <CALx6S357W+HXp4S8+tveKrqJ3-2XrZsKmBTvxZVHdwF93UWkOw@mail.gmail.com>
 <566864C0.6020204@solarflare.com>
 <CALx6S35UUmt+f4c_5Dh=8qvKBqtO7F5j_RqhXs01ONhj4HChKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Edward Cree <ecree@solarflare.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:17765 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482AbbLLQlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2015 11:41:52 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S35UUmt+f4c_5Dh=8qvKBqtO7F5j_RqhXs01ONhj4HChKw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (12/11/15 15:50), Tom Herbert wrote:
> layers of encapsulation. For example, suppose send a UDP packet in
> VXLAN in VXLAN, where packet looks like:
> IP|UDP|VXLAN|Eth|IP|UDP|VXLAN|Eth|IP|UDP. I believe the kernel can set

Without detracting from the fact that you have probably found a bug
for checksumming here..

if you have multiple encapsulations above (vxlan over vxlan?)
I think lot of other things like pmtu may also be broken?  (Each
encaps layer lowers the actual application mtu till the thing starts 
to get absurd)

--Sowmini
