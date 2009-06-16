From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Re: iproute2 action/policer question
Date: Tue, 16 Jun 2009 08:07:28 -0400
Message-ID: <1245154048.4018.18.camel@dogo.mojatatu.com>
References: <20090615111927.GA12316@ff.dom.local>
	 <1245072728.3948.14.camel@dogo.mojatatu.com>
	 <20090615214748.GA3857@ami.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f201.google.com ([209.85.221.201]:46410 "EHLO
	mail-qy0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755481AbZFPMIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 08:08:46 -0400
Received: by qyk39 with SMTP id 39so83327qyk.33
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2009 05:08:48 -0700 (PDT)
In-Reply-To: <20090615214748.GA3857@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-06-15 at 23:47 +0200, Jarek Poplawski wrote:

> 
> Jamal, after looking into act_gact or act_nat I guess we should update
> drops here likewise, unless I miss something?

It is ok for consistency. 
Nota bene: The drop is not really done by the policer; the policer
mainly suggests that the packet be dropped; so the original idea (which
is still valid) was some other action may decide to "undo" the drop. 

So feel free to add Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

cheers,
jamal

