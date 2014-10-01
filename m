From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] udp: increment UDP_NO_PORTS when dropping unmatched
 multicasts
Date: Wed, 01 Oct 2014 10:32:05 -0700
Message-ID: <542C3A95.8050804@hp.com>
References: <20141001151921.7131E29003A2@tardy> <542C23AA.6060505@oracle.com> <542C2CAB.2030501@hp.com> <542C32E6.7080106@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: David L Stevens <david.stevens@oracle.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hp.com ([15.201.208.55]:48847 "EHLO
	g4t3427.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752212AbaJARcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 13:32:07 -0400
In-Reply-To: <542C32E6.7080106@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/2014 09:59 AM, David L Stevens wrote:

> On 10/01/2014 12:32 PM, Rick Jones wrote:
>
>>
>> Do you think an "ignored" statistic would be appropriate then?
>
> I guess I don't know what that means.

It would be an added statistic for "ignored" UDP multicast datagrams, 
incremented instead of UDP_MIB_NOPORTS.  "UDP_MIB_IGNOREDMULTI" if you 
will.

Similar in concept to what HP-UX NIC drivers would increment when they 
received a frame for which there was no bound protocol - "inbound 
unknown protocols" but not a drop 
http://ptgmedia.pearsoncmg.com/images/chap1_0130428167/elementLinks/01fig16.gif

rick
