From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH: 2.6.13-15-SMP 3/3] network: concurrently run softirq
	network code on SMP
Date: Fri, 21 Sep 2007 07:47:43 -0400
Message-ID: <1190375263.4261.36.camel@localhost>
References: <002b01c7fb86$02b27df0$d6ddfea9@JOHNYE1>
	 <20070920.104614.58454013.davem@davemloft.net>
	 <00e601c7fc31$4ed29890$ca8510ac@asimco>
	 <1190375023.4261.34.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de
To: John Ye <johny@asimco.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.250]:26140 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756069AbXIULrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 07:47:46 -0400
Received: by an-out-0708.google.com with SMTP id d31so125938and
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 04:47:46 -0700 (PDT)
In-Reply-To: <1190375023.4261.34.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-21-09 at 07:43 -0400, jamal wrote:

> one cpu in either bottom/top half has to be slightly loaded and you
> loose the ordering where incoming doesnt match outgoing packet order. 

Actually in your case it gets worse because (if i read that code
correctly) you randomly select the CPUs.

cheers,
jamal

