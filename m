From: Gleb Natapov <gleb@cloudius-systems.com>
Subject: Re: [PATCH net-next v3 0/5]: ixgbevf: Allow querying VFs RSS
 indirection table and key
Date: Tue, 6 Jan 2015 21:15:46 +0200
Message-ID: <20150106191546.GD29721@cloudius-systems.com>
References: <1420467311-6680-1-git-send-email-vladz@cloudius-systems.com>
 <CALgkqUojkfTwhsoAnPZdJv-oMg7PMB5m8Q2=k5=QqXKxSJgq7w@mail.gmail.com>
 <20150106065535.GM29889@cloudius-systems.com>
 <54ABBFEB.9010105@cloudius-systems.com>
 <CALgkqUqh4uMxhnTA9yOm2m0Z3tOZ1E2+Z8Y68Kv5HJ6vP=Fk2A@mail.gmail.com>
 <20150106180455.GB29721@cloudius-systems.com>
 <1420570744.5947.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Rose <gvrose8192@gmail.com>,
	Vlad Zolotarov <vladz@cloudius-systems.com>,
	netdev@vger.kernel.org, Avi Kivity <avi@cloudius-systems.com>,
	jeffrey.t.kirsher@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:38509 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756508AbbAFTPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 14:15:50 -0500
Received: by mail-wi0-f171.google.com with SMTP id bs8so5999243wib.16
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 11:15:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1420570744.5947.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 06, 2015 at 10:59:04AM -0800, Eric Dumazet wrote:
> On Tue, 2015-01-06 at 20:04 +0200, Gleb Natapov wrote:
> > Is RSS hash security feature at all? Against what kind of attack? It
> > looks like some drivers (igb among them) use non random value for the key.
> 
> 
> Are you sure ? I thought I toko care of this already.
> 
> For igb this was in : 
> 
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=eb31f8493eee1efcc194fdc98df830a503f572f1
> 
Indeed. I looked in a couple of month old tree.

--
			Gleb.
