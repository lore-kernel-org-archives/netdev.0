From: Howard Chu <hyc@symas.com>
Subject: Re: TCP 2MSL on loopback
Date: Tue, 06 Mar 2007 15:22:37 -0800
Message-ID: <45EDF7BD.9060402@symas.com>
References: <45EDD17F.5000203@cosmosbay.com>	<45EDD791.4040908@symas.com>	<45EDDC4F.7010201@hp.com>	<20070306.133516.104036428.davem@davemloft.net>	<45EDE60D.1030706@symas.com> <20070306145403.6be2c437@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	dada1@cosmosbay.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from highlandsun.propagation.net ([66.221.212.168]:2521 "EHLO
	highlandsun.propagation.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030685AbXCFX22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 18:28:28 -0500
In-Reply-To: <20070306145403.6be2c437@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> TCP can not assume anything about the path that a packet may take.
> We have declared a moratorium on loopback benchmark foolishness.
> Go optimize the idle loop instead ;-)
Sure - A delay loop with fewer instructions is a worthwhile optimization 
because it has less impact on a CPU's instruction cache...
-- 
   -- Howard Chu
   Chief Architect, Symas Corp.  http://www.symas.com
   Director, Highland Sun        http://highlandsun.com/hyc
   Chief Architect, OpenLDAP     http://www.openldap.org/project/
