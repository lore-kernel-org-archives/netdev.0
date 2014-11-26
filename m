From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 5/5] r8169: Use eth_skb_pad function
Date: Tue, 25 Nov 2014 16:33:24 -0800
Message-ID: <54751FD4.2000003@gmail.com>
References: <20141125223727.1867.43890.stgit@ahduyck-vm-fedora20> <20141125224425.1867.70460.stgit@ahduyck-vm-fedora20> <20141126000258.GA5901@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	davem@davemloft.net
To: Francois Romieu <romieu@fr.zoreil.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:38074 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869AbaKZAd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 19:33:26 -0500
Received: by mail-pd0-f173.google.com with SMTP id ft15so1613298pdb.32
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 16:33:26 -0800 (PST)
In-Reply-To: <20141126000258.GA5901@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/2014 04:02 PM, Francois Romieu wrote:
> Alexander Duyck <alexander.h.duyck@redhat.com> :
>> Replace rtl_skb_pad with eth_skb_pad since they do the same thing.
> rtl_skb_pad returns true on success.
>
> eth_skb_pad returns 0 on success.
>

Okay, that is an easy enough fix.  I will just test for !eth_skb_pad in
the v2 version.

- Alex
