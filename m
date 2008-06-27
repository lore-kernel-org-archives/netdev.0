From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: [PATCH] TCP MD5 and TSO/SG breakage
Date: Fri, 27 Jun 2008 11:28:15 -0700
Message-ID: <396556a20806271128r5dddd07fu1affc8f61a19889b@mail.gmail.com>
References: <20080625225657.61e1b29b@extreme>
	 <396556a20806260746s351ca696xb44b9b4d6bf257c2@mail.gmail.com>
	 <20080627112118.64559f64@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"=?UTF-8?B?5ZCJ6Jek6Iux5piO?=" <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: "Stephen Hemminger" <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:61954 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762286AbYF0S2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 14:28:16 -0400
Received: by rv-out-0506.google.com with SMTP id k40so682618rvb.1
        for <netdev@vger.kernel.org>; Fri, 27 Jun 2008 11:28:15 -0700 (PDT)
In-Reply-To: <20080627112118.64559f64@speedy>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 27, 2008 at 11:21 AM, Stephen Hemminger
<stephen.hemminger@vyatta.com> wrote:
> The TCP MD5 support is broken on any device that does scatter gather.
> The MD5 calculation code doesn't support scatter/gather, the md5_calc
> API assumes the data follows the TCP header. It is too late to rework this
> code for 2.6.26 (and backport to stable). So the sane thing to do is block
> use of SG on TCP sockets using MD5 option.

Acked-By: Adam Langley <agl@imperialviolet.org>


AGL

-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
