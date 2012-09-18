From: Rick Jones <rick.jones2@hp.com>
Subject: Re: BUG: TCPDUMP invalid cksum persists after disabling TCP cksum
 offload
Date: Tue, 18 Sep 2012 14:54:38 -0700
Message-ID: <5058ED9E.1000902@hp.com>
References: <20120918193208.GA19030@darkstar> <1347998905.2685.29.camel@bwh-desktop.uk.solarflarecom.com> <20120918211423.GA19115@darkstar> <CAGK4HS9LSAGJ4amNK-rWKFNz=ZCVLkQm4sWABhY5C+6DBWsmUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamie Gloudon <jamie.gloudon@gmail.com>, netdev@vger.kernel.org
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:43042 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755341Ab2IRVyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 17:54:39 -0400
In-Reply-To: <CAGK4HS9LSAGJ4amNK-rWKFNz=ZCVLkQm4sWABhY5C+6DBWsmUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/18/2012 02:46 PM, Vijay Subramanian wrote:
>> The results after disabling tcp cksum offload feature:
>> # ethtool -K eth1 tx off
>
> Instead of this, can you try
> # ethtool -K eth1 tso off

Doesn't TSO depend on TX CKO being enabled?  That is, if TX CKO were 
disabled, shouldn't TSO have been implicitly disabled at the same time?

rick jones
