From: Sameer Rahmani <lxsameer@lxsameer.com>
Subject: Share network traffic between process with respect to a priority
 number.
Date: Wed, 25 Jul 2012 11:21:14 +0430
Message-ID: <500F9762.1090702@lxsameer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.61.134.47.78.clients.your-server.de ([78.47.134.61]:57624
	"EHLO mail.yellowen.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753158Ab2GYG6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 02:58:53 -0400
Received: from [192.168.1.151] (unknown [31.57.195.190])
	by mail.yellowen.com (Postfix) with ESMTPSA id 567AE200A3
	for <netdev@vger.kernel.org>; Wed, 25 Jul 2012 08:49:15 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys

for years i have problems with sharing my network bandwidth between my 
processes. when one of my running processes (e.g axel) start to download 
data my other processes that needs bandwidth stop working (because they 
can't download their data) . i know that there is some tools like lartc 
but i was thinking about a priority value like NICE for this matter. 
kernel will share the bandwidth between process with respect to their 
network priority number let's call it NNICE ( or what ever ) . The 
process with highest NNICE will use the highest bandwidth.

It's just an raw idea, i want to know your idea about the basic , and 
improve it.
What do you think?

With respect
Sameer Rahmani
