From: "David S. Miller" <davem@redhat.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri, 06 Sep 2002 12:24:05 -0700 (PDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20020906.122405.122283378.davem@redhat.com>
References: <20020906202646.A2185@wotan.suse.de>
	<1031339954.3d78ffb257d22@imap.linux.ibm.com>
	<20020906212619.A28172@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: ak@suse.de
In-Reply-To: <20020906212619.A28172@wotan.suse.de>
List-Id: netdev.vger.kernel.org

   From: Andi Kleen <ak@suse.de>
   Date: Fri, 6 Sep 2002 21:26:19 +0200
   
   I'm not entirely sure it is worth it in this case. The locks are
   probably the majority of the cost.

You can more localize the lock accesses (since we use per-chain
locks) by applying a cpu salt to the port numbers you allocate.

See my other email.
