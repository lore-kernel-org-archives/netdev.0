From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] CUBIC v2.3 with new improved slow start
Date: Wed, 29 Oct 2008 18:08:09 -0700
Message-ID: <490908F9.6070306@hp.com>
References: <006001c93a0d$477d4e30$4a580e98@ncsu2cc0c3fa00>	<20081029153928.3d47e26f@extreme>	<000b01c93a1c$090222c0$6c01a8c0@RHEELAPTOP>	<20081029164045.7422b68d@extreme> <4908F775.9040504@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Injong Rhee <rhee@ncsu.edu>, Injong Rhee <rhee@eos.ncsu.edu>,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:33387 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751200AbYJ3BIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 21:08:14 -0400
In-Reply-To: <4908F775.9040504@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> FWIW, HP-UX and Solaris also have ACK avoidance heursistics - they have 
> a Mentat history - although both should be pretty good and neither 
> should hold-off ACKs for two seconds...

IIRC the last time I looked at a packet trace from a link with LRO 
enabled under "Linux," that too caused "ACK avoidance" - that is we 
stray from the "ACK every other" faith.

rick jones
