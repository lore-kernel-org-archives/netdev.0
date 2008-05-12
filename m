From: David Miller <davem@davemloft.net>
Subject: Re: Socket buffer sizes with autotuning
Date: Mon, 12 May 2008 16:01:49 -0700 (PDT)
Message-ID: <20080512.160149.66601749.davem@davemloft.net>
References: <d1c2719f0805121522g4767f585h4b33790318f44264@mail.gmail.com>
	<20080512.152900.220913361.davem@davemloft.net>
	<d1c2719f0805121558m3ca01781y53e4fbd2ed451e34@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57836
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754585AbYELXBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 19:01:55 -0400
In-Reply-To: <d1c2719f0805121558m3ca01781y53e4fbd2ed451e34@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jerry Chu" <hkchu@google.com>
Date: Mon, 12 May 2008 15:58:58 -0700

> I must be missing something. All the clones share the same
> "skb_shared_info", how does one only set in_flight in one clone but
> not the other?

These are fast clones, we "know" which is the parent and which is
the child.
