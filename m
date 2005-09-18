From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: workaround large MTU and N-order allocation failures
Date: Mon, 19 Sep 2005 01:08:22 +0200
Message-ID: <20050918230822.GA5440@electric-eye.fr.zoreil.com>
References: <20050918143526.GA24181@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932269AbVIRXLc@vger.kernel.org>
To: Dan Aloni <da-x@monatomic.org>
Content-Disposition: inline
In-Reply-To: <20050918143526.GA24181@localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Aloni <da-x@monatomic.org> :
[...]
> The problem with large MTU is external memory fragmentation in
> the buddy system following high workload, causing alloc_skb() to 
> fail.

If the issue hits the Rx path, it is probably the responsibility of
the device driver. Which kind of hardware do you use ?

--
Ueimor
