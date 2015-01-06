From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 0/5]: ixgbevf: Allow querying VFs RSS
 indirection table and key
Date: Tue, 06 Jan 2015 10:59:04 -0800
Message-ID: <1420570744.5947.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1420467311-6680-1-git-send-email-vladz@cloudius-systems.com>
	 <CALgkqUojkfTwhsoAnPZdJv-oMg7PMB5m8Q2=k5=QqXKxSJgq7w@mail.gmail.com>
	 <20150106065535.GM29889@cloudius-systems.com>
	 <54ABBFEB.9010105@cloudius-systems.com>
	 <CALgkqUqh4uMxhnTA9yOm2m0Z3tOZ1E2+Z8Y68Kv5HJ6vP=Fk2A@mail.gmail.com>
	 <20150106180455.GB29721@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg Rose <gvrose8192@gmail.com>,
	Vlad Zolotarov <vladz@cloudius-systems.com>,
	netdev@vger.kernel.org, Avi Kivity <avi@cloudius-systems.com>,
	jeffrey.t.kirsher@intel.com
To: Gleb Natapov <gleb@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:40490 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbbAFS7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 13:59:07 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so75502igj.10
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 10:59:05 -0800 (PST)
In-Reply-To: <20150106180455.GB29721@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-01-06 at 20:04 +0200, Gleb Natapov wrote:
> Is RSS hash security feature at all? Against what kind of attack? It
> looks like some drivers (igb among them) use non random value for the key.


Are you sure ? I thought I toko care of this already.

For igb this was in : 

http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=eb31f8493eee1efcc194fdc98df830a503f572f1
