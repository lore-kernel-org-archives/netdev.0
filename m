From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH] net: Fix wrong sizeof
Date: Sat, 03 Oct 2009 17:38:43 +0200
Message-ID: <4AC77003.9090805@computer.org>
References: <20091002113038.1dc3d284@hyperion.delvare> <20091002.095402.42770342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay003.isp.belgacom.be ([195.238.6.53]:48016 "EHLO
	mailrelay003.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752335AbZJCPjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2009 11:39:35 -0400
Received: from [192.168.1.4] (athloroad.xperim.be [192.168.1.4])
	(authenticated bits=0)
	by via.xperim.be (8.14.2/8.14.2/Debian-2build1) with ESMTP id n93FcifJ014512
	for <netdev@vger.kernel.org>; Sat, 3 Oct 2009 17:38:47 +0200
In-Reply-To: <20091002.095402.42770342.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Any time you see "&" in a sizeof() expression, it's almost
> certainly a bug.  Something for the folks with automated
> tools to look for if they haven't already :-)

Your remark prompted me to find four more instances of such bugs (none of which in the networking bits). I have submitted patches.

Thank you.

Jan
