From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v4 3/3] TCPCT part 1c: initial SYN exchange
 with SYNACK data
Date: Mon, 02 Nov 2009 15:15:17 -0500
Message-ID: <4AEF3DD5.5050408@gmail.com>
References: <4AE6E35C.2050101@gmail.com> <4AE6E7C0.2050408@gmail.com>	 <4AEF207C.9030002@gmail.com> <1257185798.28925.33.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:15536 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932244AbZKBUPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 15:15:17 -0500
Received: by ey-out-2122.google.com with SMTP id d26so483880eyd.19
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2009 12:15:22 -0800 (PST)
In-Reply-To: <1257185798.28925.33.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches wrote:
> On Mon, 2009-11-02 at 13:10 -0500, William Allen Simpson wrote:
>> +static inline struct tcp_extend_values *tcp_xv(const struct request_values *rvp)
>> +{
>> +	return (struct tcp_extend_values *)rvp;
>> +}
>>...
> I don't know, but I do have a bias against casting
> const to non-const.
> 
Oh dear.  That's how everything in both include/linux/tcp.h and
include/net/tcp.h is done....  As I said, we've had really bad luck
using examples from the existing code base.

If somebody else submitted a patch to change all the rest, I'd be
content to follow along.
