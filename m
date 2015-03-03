From: Philippe Troin <phil@fifi.org>
Subject: Re: About Raw socket, vlan + ip header
Date: Tue, 03 Mar 2015 09:03:01 -0800
Message-ID: <1425402181.25299.1.camel@niobium.home.fifi.org>
References: <54F54327.7090002@nsn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sriram Raghunathan <sriram.r@nsn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from granite.fifsource.com ([173.255.216.206]:37837 "EHLO
	granite.fifsource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757382AbbCCRKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 12:10:06 -0500
In-Reply-To: <54F54327.7090002@nsn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-03-03 at 10:44 +0530, Sriram Raghunathan wrote:
> Writing a socket program where, I'm trying to construct a ether frame
> with vlan id and copying ip header there after. By using PF_PACKET
> family.
> 
> But when I do a sendto, the ip header is stripped off from the
> packet. Could you please let me know how to go about?

man 7 packet

...
       The  socket_type  is either SOCK_RAW for raw packets including the link
       level header or SOCK_DGRAM for  cooked  packets  with  the  link  level
       header  removed.   The  link level header information is available in a
       common format in a sockaddr_ll.  protocol is the  IEEE  802.3  protocol
...

Are you opening a SOCK_RAW or a SOCK_DGRAM PF_PACKET socket?

Phil.
