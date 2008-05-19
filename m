From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 10737] New: pktgen procfs problem
Date: Mon, 19 May 2008 12:34:55 +0200
Message-ID: <483157CF.5080201@trash.net>
References: <bug-10737-10286@http.bugzilla.kernel.org/>	 <20080517141036.d8f3c768.akpm@linux-foundation.org>	 <482F88DE.8090508@trash.net>	 <20080517215641.acb94677.akpm@linux-foundation.org>	 <48301BE0.9040907@trash.net> <48302E09.8080701@trash.net>	 <48304BB5.7090805@trash.net> <1211183642.9966.6.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, devzero@web.de,
	Robert Olsson <robert.olsson@its.uu.se>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Ben Greear <greearb@candelatech.com>
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64796 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752496AbYESKgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 06:36:13 -0400
In-Reply-To: <1211183642.9966.6.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis V. Lunev wrote:
> On Sun, 2008-05-18 at 17:31 +0200, Patrick McHardy wrote:
>   
>> git-bisect identified e9720acd ([NET]: Make /proc/net a symlink
>> on /proc/self/net (v3)) as the guilty commit. I couldn't find
>> the problem in that commit, so someone with a better understanding
>> of how this is supposed to work should look into it.
>>     
>
> could you consider this preliminary patch? It fixes the problem for me
> and Pavel agrees with it.
>
> The problem is that module_get is called for each file opening while
> module_put is called only when /proc inode is destroyed. So, lets put
> module counter if we are dealing with already initialised inode.
>   


The patch works fine for me, thanks.
