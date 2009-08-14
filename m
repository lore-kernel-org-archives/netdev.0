From: Aviv Greenberg <avivgnet@gmail.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Sat, 15 Aug 2009 00:13:12 +0300
Message-ID: <3000d2e90908141413h3e3eae1dm796f4bf788319561@mail.gmail.com>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>
	 <20090808112636.GB18518@localhost.localdomain>
	 <4A7DC230.6060206@myri.com>
	 <20090808183251.GA23300@localhost.localdomain>
	 <20090811033210.6b422ed1.billfink@mindspring.com>
	 <87ws5af0km.fsf@basil.nowhere.org>
	 <20090812003049.185cd52a.billfink@mindspring.com>
	 <4A856781.2080301@myri.com>
	 <20090814123832.a7a27a9d.billfink@mindspring.com>
	 <4A859716.7040904@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Bill Fink <billfink@mindspring.com>, netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:47981 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755238AbZHNVNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 17:13:12 -0400
Received: by bwz22 with SMTP id 22so1361528bwz.18
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 14:13:13 -0700 (PDT)
In-Reply-To: <4A859716.7040904@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  There may be something in the chipset

shooting in the dark: when you lspci -vvv and check the MaxPayload and
MaxReadReq values for the myri devices - what are the values and are
they equal? Are they the same on all your platforms?
