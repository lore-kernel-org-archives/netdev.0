From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.{4,x5}.x] mod_timer cleanups for dst.c
Date: Sun, 04 May 2003 04:26:12 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030504.042612.104038287.davem@redhat.com>
References: <1052040334.1119.71.camel@lima.royalchallenge.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: vinay-rc@naturesoft.net
In-Reply-To: <1052040334.1119.71.camel@lima.royalchallenge.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Vinay K Nallamothu <vinay-rc@naturesoft.net>
   Date: 04 May 2003 14:55:34 +0530

   Just reposting what I earlier posted to the linux-kernel mailing list.
   These are trivial patches converting {del,add}_timer to mod_timer.

Thanks, this is actually a bug fix.  The old code could add_timer()
while the timer was active.
