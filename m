From: Howard Chu <hyc@symas.com>
Subject: Re: TCP 2MSL on loopback
Date: Tue, 06 Mar 2007 19:36:35 -0800
Message-ID: <45EE3343.3010905@symas.com>
References: <45EBFD13.1060106@symas.com>	<200703051528.02564.dada1@cosmosbay.com>	<45ED32CA.5080709@symas.com> <45EDB708.1010103@hp.com> <45EDC00E.8020805@symas.com> <45EDD1DC.2010200@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from highlandsun.propagation.net ([66.221.212.168]:2835 "EHLO
	highlandsun.propagation.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030790AbXCGDmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 22:42:19 -0500
In-Reply-To: <45EDD1DC.2010200@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> The timeout is also to cover datagrams which just got "stuck" somewhere 
> too (IIRC) and may not necessarily require a multiple path situation.

I guess that's a fair point. Originally, the only possible place for a
packet to get "stuck" was in a router but I suppose that may no longer
be true.

> True.  Thankfully, the web learned to use persistent connections so 
> later versions of SPECweb benchmarking make use of persistent connections.

As a complete aside, I think it's about time for a SPECldap benchmark...
-- 
   -- Howard Chu
   Chief Architect, Symas Corp.  http://www.symas.com
   Director, Highland Sun        http://highlandsun.com/hyc
   Chief Architect, OpenLDAP     http://www.openldap.org/project/

