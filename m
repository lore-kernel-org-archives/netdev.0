From: kuznet@ms2.inr.ac.ru
Subject: Re: [patch] bug prematurely setting nr_frags
Date: Wed, 14 Aug 2002 02:27:56 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208132227.CAA22255@sex.inr.ac.ru>
References: <20020813143120.C12730@redhat.com>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: bcrl@redhat.com (Benjamin LaHaise)
In-Reply-To: <20020813143120.C12730@redhat.com> from "Benjamin LaHaise" at Aug 13, 2 02:31:20 pm
List-Id: netdev.vger.kernel.org

Hello!

> Ah, I see.  Care for a patch to remove it altogether then?

Well, someone wrote it for some purpose. :-) 


>							  As for the 
> bug, does anyone else see a place where nr_frags can be set without 
> initializing a page pointer? 

No. When does this happen?


> Otherwise it looks like a random memory corruption... what fun.

Well, even if this is corruption, it is unlikely to be random.
This maybe write beyond end of an skb, corrupting skb_shared_info.
At least, we had such place in netfilter fixed some time ago.

Alexey
