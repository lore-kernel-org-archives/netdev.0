From: "David S. Miller" <davem@redhat.com>
Subject: Re: simple change to qdisc_restart()
Date: Tue, 20 May 2003 01:28:24 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030520.012824.85398613.davem@redhat.com>
References: <20030520082217.GC978@udine>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric.Lemoine@Sun.COM
In-Reply-To: <20030520082217.GC978@udine>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Eric Lemoine <Eric.Lemoine@Sun.COM>
   Date: Tue, 20 May 2003 10:22:17 +0200
   
   Any comments regarding the following patch?

I understand why it is valid, etc., but why do we even want to do
this?  It is not like this dead-loop detection stuff is a hot-path or
anything like that.
