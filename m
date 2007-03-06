From: Howard Chu <hyc@symas.com>
Subject: Re: TCP 2MSL on loopback
Date: Tue, 06 Mar 2007 13:05:21 -0800
Message-ID: <45EDD791.4040908@symas.com>
References: <45EBFD13.1060106@symas.com> <200703051528.02564.dada1@cosmosbay.com> <45ED32CA.5080709@symas.com> <200703061142.00261.dada1@cosmosbay.com> <45EDB55C.2080803@symas.com> <45EDCA15.4060704@cosmosbay.com> <45EDCEF5.1070401@symas.com> <45EDD17F.5000203@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from highlandsun.propagation.net ([66.221.212.168]:2242 "EHLO
	highlandsun.propagation.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751133AbXCFVLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 16:11:09 -0500
In-Reply-To: <45EDD17F.5000203@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:

> Arf... dont tell me you forgot to do this...
> 
> echo 1 >/proc/sys/net/ipv4/tcp_tw_recycle
> echo 1 >/proc/sys/net/ipv4/tcp_tw_reuse

That does not appear to me to be a safe thing to do on a production 
machine. Tweaks that are only good in a test environment really don't 
help the testing effort; they just mask a problem that will surface 
later at deployment time.

We could run our benchmarks this way and get high rates but no one 
deploying the server for real use would ever get anything like that, 
which makes the benchmark figure rather pointless.

On the other hand, being able to configure a small MSL for the loopback 
device is perfectly safe. Being able to configure a small MSL for other 
interfaces may be safe, depending on the rest of the network layout.
-- 
   -- Howard Chu
   Chief Architect, Symas Corp.  http://www.symas.com
   Director, Highland Sun        http://highlandsun.com/hyc
   Chief Architect, OpenLDAP     http://www.openldap.org/project/
