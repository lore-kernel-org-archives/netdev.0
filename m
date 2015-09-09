From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: Re: [PATCH v6 02/10] ss: created formatters for json and hr
Date: Thu, 10 Sep 2015 00:00:36 +0200
Message-ID: <55F0AC04.7090605@gmx.net>
References: <1441827801-9617-1-git-send-email-matthias.tafelmeier@gmx.net>
 <4b7ff1016053461a80465ce8138e12a2@HQ1WP-EXMB11.corp.brocade.com>
 <20150909143049.0aa08d37@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hagen@jauu.net" <hagen@jauu.net>,
	"shemminger@osdl.org" <shemminger@osdl.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"edumazet@google.com" <edumazet@google.com>,
	"daniel@iogearbox.net" <daniel@iogearbox.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:63909 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754369AbbIIWAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2015 18:00:50 -0400
In-Reply-To: <20150909143049.0aa08d37@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +#define STATIC_ASSERT(COND, MSG)			\
>> +{							\
>> +	char STATIC_ASSERT##MSG[(COND) ? 1 : -1];	\
>> +	(void)STATIC_ASSERT##MSG[0];		\
>> +}
> 
> If you are going to introduce this, please use same convention
> as Linux kernel. ie. BUILD_BUG_ON()
> 
> Your code looks like it came out of some other project.
> 

Well, but when using "BUILD_BUG_ON()" I would have to give up on having
put out the MSG by compiler when a static issue occurs. I liked that notion.
