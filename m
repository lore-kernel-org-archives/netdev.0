From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Date: Tue, 08 Aug 2006 15:10:20 -0700 (PDT)
Message-ID: <20060808.151020.94555184.davem@davemloft.net>
References: <20060808193325.1396.58813.sendpatchset@lappy>
	<20060808193345.1396.16773.sendpatchset@lappy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, phillips@google.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030317AbWHHWKR@vger.kernel.org>
To: a.p.zijlstra@chello.nl
In-Reply-To: <20060808193345.1396.16773.sendpatchset@lappy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I think the new atomic operation that will seemingly occur on every
device SKB free is unacceptable.

You also cannot modify netdev->flags in the lockless manner in which
you do, it must be done with the appropriate locking, such as holding
the RTNL semaphore.
