From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: Generic Netlink HOW-TO based on Jamal's original doc
Date: Fri, 10 Nov 2006 15:17:48 -0800
Message-ID: <4555089C.1040409@oracle.com>
References: <45541757.90800@hp.com> <20061110102318.7b344d30.randy.dunlap@oracle.com> <20061110221219.GM8693@postel.suug.ch> <45550212.5060207@oracle.com> <20061110225614.GO8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <paul.moore@hp.com>, hadi@cyberus.ca,
	netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:27176 "EHLO
	agminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1424466AbWKJXSS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 18:18:18 -0500
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061110225614.GO8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Randy Dunlap <randy.dunlap@oracle.com> 2006-11-10 14:49
>>> I thought I chose GENL_NAMESIZ wisely but to be sure I checked
>>> with Mr. Alignment himself, Arnaldo:
>> Hm, looks OK to me.  Am I missing something?
> 
> It is OK, I was merely trying to prove it :-)
> 
>>> struct genl_family {
>>>        unsigned int               id;                   /* 0(0)     4 */
>>>        unsigned int               hdrsize;              /* 4(0)     4 */
>>>        char                       name[16];             /* 8(0)    16 */
>>>        unsigned int               version;              /* 24(0)     4 */
>>>        unsigned int               maxattr;              /* 28(0)     4 */
>>>        /* ---------- cacheline 1 boundary ---------- */
>>>        struct nlattr * *          attrbuf;              /* 32(0)     4 */
>>>        struct list_head           ops_list;             /* 36(0)     8 */
>>>        struct list_head           family_list;          /* 44(0)     8 */
>>> }; /* size: 52 */
>> How about field size issues?  Usually for int's etc. that are in
>> userspace interfaces, we use __u32 etc.
> 
> This is kernel side only, struct genl_family lives in net/genetlink.h
> and is not exported to userspace.

OK, thanks for the clarifications.

-- 
~Randy
