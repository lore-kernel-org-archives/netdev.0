From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Panic in ipv6_add_dev
Date: Wed, 11 Jun 2003 23:35:28 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030611.233528.26511069.davem@redhat.com>
References: <3EE52C92.4060509@us.ibm.com>
	<20030610.135601.20565349.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, krkumar@us.ibm.com
Return-path: <linux-net-owner@vger.kernel.org>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030610.135601.20565349.yoshfuji@linux-ipv6.org>
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Tue, 10 Jun 2003 13:56:01 +0900 (JST)

   Well, it is also the problem that the tasks of 
     neigh_parms_alloc() / neigh_sysctl_register()
   and 
     neigh_parms_release() / neigh_sysctl_unregister()
   were not symmetric.
 ...   
   Here's the fix.

Patch applied, thanks.
