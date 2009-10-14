From: Tim Schneider <schneid5@cs.uni-bonn.de>
Subject: Route Metric at Kernel Level
Date: Wed, 14 Oct 2009 22:49:11 +0200
Message-ID: <F1DCC2D4-C845-414D-99E3-D402E7950838@cs.uni-bonn.de>
Mime-Version: 1.0 (Apple Message framework v1076)
Content-Type: text/plain; charset=us-ascii; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Nils Aschenbruck <aschenbruck@cs.uni-bonn.de>,
	Christoph Fuchs <cf@cs.uni-bonn.de>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix.iai.uni-bonn.de ([131.220.8.4]:64161 "EHLO
	postfix.iai.uni-bonn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756106AbZJNVFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 17:05:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I've been trying for a while now, to readout the Routing-Metric from a  
given socket at kernel level. So far, I've always set the routing- 
table metric by hand using the ifmetric command.
When I tried reading out the struct sock->sk_dst_cache->metrics  
values, I always got a Metric value which was 0. I thought I was  
reading out the wrong value, until I discovered, that the metric  
values, that I put into the standard routing table are not copied into  
the kernel routing cache which I was reading out. Now I am wondering  
if it is supposed to be like that, and if so, why it was implemented  
that way.

Also, since I need to read out the Metric value from the Routing  
Table, I am in need of some help. Maybe just a push into the right  
direction. I've been looking at the fib_frontend.c and the other fib_*  
files which, as I understand, implement the routing tables.  
Unfortunately they don't seem to export their functions for my Kernel- 
Module, so I am unable to use those. Is there an entrypoint from where  
I am able to use the functions given in the fib_* files, or are they  
strictly closed off from the rest of the Kernel?

Thank you for any help!

Greetings

Tim
