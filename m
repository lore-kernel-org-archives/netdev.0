From: Raz <raziebe@gmail.com>
Subject: Question: alloc_skb_from_cache
Date: Sat, 14 Feb 2009 19:49:54 +0200
Message-ID: <5d96567b0902140949u277b4a3dmd7476f199654d0ad@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:60252 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751507AbZBNRt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 12:49:56 -0500
Received: by fxm13 with SMTP id 13so4506687fxm.13
        for <netdev@vger.kernel.org>; Sat, 14 Feb 2009 09:49:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hello
I am trying to understand how alloc_skb_from_cache worked ( when it
was part of the mainline ).
I am interested in this api be cause it is easier to find memory leaks
using slabs.
But , when releasing skb:

__kfree_skb()
    slb_release_data()
         kfree(skb->head)

skb->head points contains a private cache object pointer and it is
being released to a general purpose cache ?

thank you
