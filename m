From: kuznet@ms2.inr.ac.ru
Subject: Re: [patch] bug prematurely setting nr_frags
Date: Tue, 13 Aug 2002 08:06:13 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208130406.IAA20038@sex.inr.ac.ru>
References: <20020812190744.R1781@redhat.com>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: bcrl@redhat.com (Benjamin LaHaise)
In-Reply-To: <20020812190744.R1781@redhat.com> from "Benjamin LaHaise" at Aug 12, 2 07:07:44 pm
List-Id: netdev.vger.kernel.org

Hello!

> Huh?  It's called from sock_alloc_send_skb, which is called from all 
> over the stack.

It is used with data_len==0. The branch generating fragments is dead.

Alexey
