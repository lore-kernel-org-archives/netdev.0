From: Aron Griffis <aron@hp.com>
Subject: ifconfig bug removes aliases
Date: Wed, 10 Mar 2004 16:20:56 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040310212056.GA5661@time.flatmonk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello, here is the sequence:

    ifconfig eth0:1 10.10.10.1 netmask 255.255.0.0 
    ifconfig eth0:2 10.10.10.2 netmask 255.255.0.0 
    ifconfig eth0:1 down

At this point eth0:2 has disappeared also.  It appears that the aliases
must be on the same subnet for this to occur, and the creation order is
also important.

Aron
