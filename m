From: "David S. Miller" <davem@redhat.com>
Subject: Windows XP zero initial timestamps
Date: Tue, 28 Oct 2003 00:58:42 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031028005842.091c93a9.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, b_wydrowski@yahoo.com.au, casey@carter.net,
        ccarter@cs.uiuc.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This is for the people who brought up the zero timestamp
issue with Windows XP.

It may be allowed by RFC1323, but always using a zero
initial timestamp breaks PAWS.

PAWS depends upon each end-host using a single host-wide timestamp
source for all connections.

I can't even imagine what XP is trying to accomplish by using
a zero-based timestamp for all connections.  But there is no
doubt that it breaks PAWS.

The best we could ever do is to allow zero initial timestamps but to
disable PAWS when using timestamps with such systems.

Someone should contact the windows networking coders, I doubt they
broke PAWS intentionally.
