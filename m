From: Eric Lemoine <Eric.Lemoine@ens-lyon.fr>
Subject: socket lock question
Date: Mon, 17 Feb 2003 17:46:41 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030217164640.GC289@udine>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi

It seems to me that sk->slock.lock is grabbed twice successively in the
same code path, namely in tcp_v4_rcv() and tcp_v4_do_rcv(). 

Does anyone know how this is possible?
-- 
Eric
