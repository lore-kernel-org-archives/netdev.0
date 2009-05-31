From: Minoru Usui <mi.usui@gmail.com>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sun, 31 May 2009 10:45:45 +0900
Message-ID: <b10243b50905301845k16d72939u6b636a0a3f0fceea@mail.gmail.com>
References: <20090529225929.GD2753@ami.dom.local>
	 <20090530120750.GB3166@ami.dom.local>
	 <1243686683.3966.117.camel@dogo.mojatatu.com>
	 <20090530124554.GC3166@ami.dom.local>
	 <1243688628.3966.126.camel@dogo.mojatatu.com>
	 <20090530132047.GD3166@ami.dom.local>
	 <1243690297.3966.135.camel@dogo.mojatatu.com>
	 <20090530140006.GE3166@ami.dom.local>
	 <b10243b50905301538o2716855ag21fbc95b37c8da22@mail.gmail.com>
	 <1243726492.3966.178.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Minoru Usui <usui@mxm.nes.nec.co.jp>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f130.google.com ([209.85.221.130]:33647 "EHLO
	mail-qy0-f130.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753850AbZEaBpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 21:45:44 -0400
Received: by qyk36 with SMTP id 36so767998qyk.33
        for <netdev@vger.kernel.org>; Sat, 30 May 2009 18:45:45 -0700 (PDT)
In-Reply-To: <1243726492.3966.178.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/5/31 jamal <hadi@cyberus.ca>:
> On Sun, 2009-05-31 at 07:38 +0900, Minoru Usui wrote:
>
>> I agree.
>> I think cls_cgroup should check head(tp->root) whether NULL or not
>> like other classifiers, too.
>>
>
> I dont think this is necessary if the adding/linking unconfigured tp
> doesnt happen on failed config.

Ah, you are right.
Sorry, I don't explain enough.

I mean it needs just for safety.
