From: Dmitry Mishin <dim@openvz.org>
Subject: Re: [Devel] Re: [RFC] network namespaces
Date: Mon, 11 Sep 2006 19:10:31 +0400
Message-ID: <200609111910.31624.dim@openvz.org>
References: <20060815182029.A1685@castle.nmd.msu.ru> <4505757B.3020004@fr.ibm.com> <20060911145724.GB27223@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	Kir Kolyshkin <kir@openvz.org>, Andrey Savochkin <saw@sw.ru>,
	netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>, alexey@sw.ru,
	sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:52515 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S964792AbWIKPLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2006 11:11:51 -0400
To: Herbert Poetzl <herbert@13thfloor.at>
In-Reply-To: <20060911145724.GB27223@MAIL.13thfloor.at>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 11 September 2006 18:57, Herbert Poetzl wrote:
> I completely agree here, we need a separate namespace
> for that, so that we can combine isolation and virtualization
> as needed, unless the bind restrictions can be completely
> expressed with an additional mangle or filter table (as
> was suggested)
iptables are designed for packet flow decisions and filtering, it has nothing 
common with bind restrictions. So, it may be only packet flow 
scheduling/filtering, but it will not help to resolve bind-time IP conflicts.

-- 
Thanks,
Dmitry.
