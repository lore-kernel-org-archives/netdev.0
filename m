From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] make sendmsg return EDESTADDRREQ if socket is not
 connected and daddr was not specified
Date: Thu, 10 Jul 2003 17:29:35 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030710.172935.77037127.davem@redhat.com>
References: <20030710233223.GA30577@rei.rakuen>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch
In-Reply-To: <20030710233223.GA30577@rei.rakuen>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Thomas Graf <tgraf@suug.ch>
   Date: Fri, 11 Jul 2003 01:32:23 +0200

   [EDESTADDRREQ]
       The socket is not connection-mode and does not have its peer
       address set, and no destination address was specified.
   
   fixes sendmsg in ipv{4,6}/{raw,udp}

Applied, thanks Thomas.
