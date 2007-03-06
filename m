From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP 2MSL on loopback
Date: Tue, 06 Mar 2007 13:25:35 -0800
Message-ID: <45EDDC4F.7010201@hp.com>
References: <45EBFD13.1060106@symas.com>	<200703051528.02564.dada1@cosmosbay.com>	<45ED32CA.5080709@symas.com>	<200703061142.00261.dada1@cosmosbay.com>	<45EDB55C.2080803@symas.com> <45EDCA15.4060704@cosmosbay.com>	<45EDCEF5.1070401@symas.com> <45EDD17F.5000203@cosmosbay.com> <45EDD791.4040908@symas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: Howard Chu <hyc@symas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:48586 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965109AbXCFVZj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 16:25:39 -0500
In-Reply-To: <45EDD791.4040908@symas.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On the other hand, being able to configure a small MSL for the loopback 
> device is perfectly safe. Being able to configure a small MSL for other 
> interfaces may be safe, depending on the rest of the network layout.

A peanut gallery question - I seem to recall prior discussions about how 
one cannot assume that a packet destined for a given IP address will 
remain detined for that given IP address as it could go through a module 
that will rewrite headers etc.

Is traffic destined for 127.0.0.1 immune from that?

rick jones
