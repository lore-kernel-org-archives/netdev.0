From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] make {send|recv}msg return code 1003.1 compatible
Date: Wed, 09 Jul 2003 22:52:41 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030709.225241.98880784.davem@redhat.com>
References: <20030709193628.GR2702@rei.rakuen>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch
In-Reply-To: <20030709193628.GR2702@rei.rakuen>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Thomas Graf <tgraf@suug.ch>
   Date: Wed, 9 Jul 2003 21:36:28 +0200

   1003.1 says:
   
   [EMSGSIZE]
       The msg_iovlen member of the msghdr structure pointed to by
       message is less than or equal to 0, or is greater than
       {IOV_MAX}.
   
   The patch changes the return code of {send|recv}msg from EINVAL
   to EMSGSIZE.

Patch applied, thanks.
