From: "David S. Miller" <davem@redhat.com>
Subject: Re: acenic lockup
Date: Tue, 06 May 2003 23:43:16 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030506.234316.68138442.davem@redhat.com>
References: <20030507070657.GC30976@krispykreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jes@trained-monkey.org, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: anton@samba.org
In-Reply-To: <20030507070657.GC30976@krispykreme>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Anton Blanchard <anton@samba.org>
   Date: Wed, 7 May 2003 17:06:57 +1000
   
   Its stuck there and never coming out. Alexey: I have a feeling you
   wrote this code, is that correct? :)

It is well understood failure of this driver, actually.

If Acenic hangs in any way at all, driver hangs in this loop.
