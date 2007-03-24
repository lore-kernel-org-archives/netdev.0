From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH 1/5 2.6.21-rc4] l2tp: pppol2tp core
Date: Sat, 24 Mar 2007 17:37:39 +0000
Message-ID: <460561E3.9020502@katalix.com>
References: <200703232307.l2NN7Rtg010808@quickie.katalix.com> <20070324002242.GA26017@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Zumbiehl <florz@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:44713 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932468AbXCXRhl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Mar 2007 13:37:41 -0400
In-Reply-To: <20070324002242.GA26017@florz.florz.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Zumbiehl wrote:
> Hi,
> 
>> + * 251003 :	Copied from pppoe.c version 0.6.9.
> 
> you might want to have a look at the patches to the PPPoE code that were
> posted to netdev recently, as some of them seem to apply to code that's
> left over from pppoe.c.

Do you mean this change?

  * 070228 : Fix to allow multiple sessions with same remote MAC and same
  *	    session id by including the local device ifindex in the
  *	    tuple identifying a session. This also ensures packets can't
  *          be injected into a session from interfaces other than the
  *          one	specified by userspace. Florian Zumbiehl <florz@gmx.de>

The pppoe session hash table isn't used in the pppol2tp code so the 
above change doesn't affect pppol2tp. I rechecked the latest pppoe.c and 
I don't see other changes that haven't already been incorporated in 
pppol2tp. Which specific code in pppol2tp do you think needs to be updated?

Thanks

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

