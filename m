From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC][PATCH 0/3] TCP/IP Critical socket communication mechanism
Date: Wed, 14 Dec 2005 10:22:28 +0100
Message-ID: <20051214092228.GC18862@brahms.suse.de>
References: <Pine.LNX.4.58.0512140042280.31720@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932243AbVLNJWd@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0512140042280.31720@w-sridhar.beaverton.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I would appreciate any feedback or comments on this approach.

Maybe I'm missing something but wouldn't you need an own critical
pool (or at least reservation) for each socket to be safe against deadlocks?

Otherwise if a critical sockets needs e.g. 2 pages to finish something
and 2 critical sockets are active they can each steal the last pages
from each other and deadlock.

-Andi
