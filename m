From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Make xfrm subsystem optional
Date: Sat, 14 Jun 2003 02:27:02 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030614.022702.41637600.davem@redhat.com>
References: <20030614091631.GA16993@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@suse.de
In-Reply-To: <20030614091631.GA16993@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andi Kleen <ak@suse.de>
   Date: Sat, 14 Jun 2003 11:16:31 +0200
   
   This patches only compiles the xfrm subsystem in when any of the options
   using it are selected. This shrinks the text segment on an amd64
   kernel by ~32k, data by ~6k, bss by ~33k, overall ~72K memory saved.

I'm not going to apply this, sorry Andi.

I want the freedom to use the XFRM layer for generic things
at some point.

How about working on making the xfrm layer more lean instead? :)
