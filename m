From: Janice Girouard <girouard@us.ibm.com>
Subject: Re: patch for common networking error messages
Date: Mon, 16 Jun 2003 17:29:15 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFF1F6B3DC.30C0E5DE-ON85256D47.007AEFAF@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Daniel Stekloff <stekloff@us.ibm.com>, janiceg@us.ibm.com,
   jgarzik@pobox.com, kenistonj@us.ibm.com,
   Larry Kessler <lkessler@us.ibm.com>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, niv@us.ibm.com, <niv@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: "David S. Miller" <davem@redhat.com>
   Date : 06/16/2003 05:13 PM

   egrep "promiscuous mode" net/core/dev.c | grep printk

I noticed when I performed the grep, the printk shows:
      printk(KERN_INFO "device %s %s promiscuous mode\n"

For the sake of consistency and automatic error log analysis, it might be
nice to standardize on a message closer to:
      printk(KERN_INFO "%s: %s promiscuous mode\n"

It's somewhat common, but not universal to start the error message with the
device name followed by a colon.

Janice
