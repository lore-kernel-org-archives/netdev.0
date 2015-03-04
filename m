From: Sriram Raghunathan <srirr@nsn-intra.net>
Subject: Re: About Raw socket, vlan + ip header
Date: Wed, 04 Mar 2015 10:06:58 +0530
Message-ID: <54F68BEA.8040605@nsn-intra.net>
References: <54F54327.7090002@nsn.com> <1425402181.25299.1.camel@niobium.home.fifi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ext Philippe Troin <phil@fifi.org>,
	Sriram Raghunathan <sriram.r@nsn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:36768 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755647AbbCDEtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 23:49:39 -0500
In-Reply-To: <1425402181.25299.1.camel@niobium.home.fifi.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Philippe,

Using SOCK_RAW.

Sriram
On Tuesday 03 March 2015 10:33 PM, ext Philippe Troin wrote:
> On Tue, 2015-03-03 at 10:44 +0530, Sriram Raghunathan wrote:
>> Writing a socket program where, I'm trying to construct a ether frame
>> with vlan id and copying ip header there after. By using PF_PACKET
>> family.
>>
>> But when I do a sendto, the ip header is stripped off from the
>> packet. Could you please let me know how to go about?
> man 7 packet
>
> ...
>         The  socket_type  is either SOCK_RAW for raw packets including the link
>         level header or SOCK_DGRAM for  cooked  packets  with  the  link  level
>         header  removed.   The  link level header information is available in a
>         common format in a sockaddr_ll.  protocol is the  IEEE  802.3  protocol
> ...
>
> Are you opening a SOCK_RAW or a SOCK_DGRAM PF_PACKET socket?
>
> Phil.
>
