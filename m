From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Panic in ipv6_add_dev
Date: Wed, 11 Jun 2003 23:22:52 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030611.232252.68134856.davem@redhat.com>
References: <3EE52C92.4060509@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: krkumar@us.ibm.com
In-Reply-To: <3EE52C92.4060509@us.ibm.com>
List-Id: netdev.vger.kernel.org

   From: Krishna Kumar <krkumar@us.ibm.com>
   Date: Mon, 09 Jun 2003 17:55:46 -0700
   
   We need to initialize sysctl_table to NULL in neigh_parms_alloc so that a 
   release can be called safely at any time.

Patch applied, thanks.
