From: Patrick McHardy <kaber@trash.net>
Subject: Re: HFSC dangerous behaviour (not a bug)
Date: Mon, 29 Oct 2007 11:56:52 +0100
Message-ID: <4725BC74.9040407@trash.net>
References: <20071029005547.M47431@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57279 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751992AbXJ2K7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 06:59:08 -0400
In-Reply-To: <20071029005547.M47431@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys wrote:
> Additionally, it doesn't show rate in stats (so it is difficult to measure, 
> how much is really using each class).
> 
> qdisc hfsc 1: root default 200
>  Sent 1392761062 bytes 965768 pkt (dropped 52, overlimits 1620539 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0


Thats what rate estimators are for. Add something like "estimator 1 4"
to your qdisc and class creation commands to measure the rate.


