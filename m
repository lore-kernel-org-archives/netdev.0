From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: very strange inet_sock corruption with rpc
Date: Thu, 26 Apr 2007 09:00:27 -0400
Message-ID: <4630A26B.2050406@hp.com>
References: <462FC238.4040305@hp.com> <200704260849.41485.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Olaf Kirch <okir@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:43347 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030781AbXDZNA3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 09:00:29 -0400
In-Reply-To: <200704260849.41485.okir@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olaf Kirch wrote:
> On Wednesday 25 April 2007 23:03, Vlad Yasevich wrote:
>> It looks like someone is stepping all over the inet_sock.
>> We'll continue looking, but if anyone has any ideas of what might
>> be going on, I'd appreciate it.
> 
> This could be a socket in TIME_WAIT. A socket entering
> TIME_WAIT will be replaced by an inet_timewait_sock, which is
> a kind of truncated inet_sock.
> 
> Olaf

Olaf

Thank you.  I think this is what we are seeing.

-vlad
