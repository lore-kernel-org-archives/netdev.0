From: Paul Moore <paul.moore@hp.com>
Subject: Re: Generic Netlink HOW-TO based on Jamal's original doc
Date: Fri, 10 Nov 2006 14:50:05 -0500
Message-ID: <4554D7ED.4030802@hp.com>
References: <45541757.90800@hp.com> <20061110102318.7b344d30.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:25252 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1946783AbWKJTuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 14:50:07 -0500
To: Randy Dunlap <randy.dunlap@oracle.com>
In-Reply-To: <20061110102318.7b344d30.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy Dunlap wrote:
> On Fri, 10 Nov 2006 01:08:23 -0500 Paul Moore wrote:
> 
>>An Introduction To Using Generic Netlink
>>===============================================================================
>>3.1.2. The genl_family Structure
>>
>>Generic Netlink services are defined by the genl_family structure, which is
>>shown below:
>>
>>  struct genl_family
>>  {
>>        unsigned int            id;
>>        unsigned int            hdrsize;
>>        char                    name[GENL_NAMSIZ];
>>        unsigned int            version;
>>        unsigned int            maxattr;
>>        struct nlattr **        attrbuf;
>>        struct list_head        ops_list;
>>        struct list_head        family_list;
>>  };
> 
> Any alignment/packing concerns here?  or that is already
> handled, just not presented here?
> 
> and same questions for other structs below (deleted).

These structure contents/layout were taken straight from the code.

> Typo patch attached.

Applied, thanks.

-- 
paul moore
linux security @ hp
