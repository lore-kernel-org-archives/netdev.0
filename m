From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH net-next] [RFC] netns: enable cross-ve Unix sockets
Date: Wed, 01 Oct 2008 16:40:58 +0400
Message-ID: <48E36FDA.5090808@openvz.org>
References: <1222858454-7843-1-git-send-email-den@openvz.org> <48E35B4C.1040303@fr.ibm.com> <1222860776.23573.49.camel@iris.sw.ru> <48E3653C.1070701@fr.ibm.com> <1222862583.23573.54.camel@iris.sw.ru> <48E36ABF.8030908@fr.ibm.com> <48E36BFA.3040904@openvz.org> <48E36DA0.9080400@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	benjamin.thery@bull.net, ebiederm@xmission.com,
	Denis Lunev <den@openvz.org>
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:41657 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753426AbYJAMnH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 08:43:07 -0400
In-Reply-To: <48E36DA0.9080400@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano wrote:
> Pavel Emelyanov wrote:
>>> So there are 2 cases:
>>>   * full isolation : restriction on VPS
>>>   * partial isolation : no restriction but *perhaps* problem when migrating
>>>
>>> Looks like we need an option per namespace to reduce the isolation for 
>>> af_unix sockets :)
>>>   - on (default): current behaviour => full isolation
>>>   - off : partial isolation
>> You mean some sysctl, that enables/disables this check in unix_find_socket_byinode?
> 
> Yes.

OK. Den, please, do :)
