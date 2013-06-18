From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: UDP "accept" proposed
Date: Tue, 18 Jun 2013 11:52:25 +0200
Message-ID: <51C02DD9.3050308@redhat.com>
References: <51C01EDA.30705@openvpn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Yonan <james@openvpn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14618 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754396Ab3FRJw2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jun 2013 05:52:28 -0400
In-Reply-To: <51C01EDA.30705@openvpn.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/18/2013 10:48 AM, James Yonan wrote:
[...]
> This is a disaster from a performance perspective because you can't take a UDP server that
 > binds to a single port and efficiently scale it up across multiple threads or processors
 > because you must operate off a single socket.
[...]
> But this would be a huge performance win for UDP servers (I'm thinking about OpenVPN in
 > particular) because making the kernel smarter about dispatching UDP datagrams would make it
 > much easier to develop scalable UDP servers on Linux.

So SO_REUSEPORT that was added in 3.9 by Tom Herbert wouldn't
help in your case (+ f.e. steering flows to CPUs locally) ?

   https://lwn.net/Articles/542629/
