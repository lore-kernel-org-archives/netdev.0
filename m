From: Peter Buckingham <peter@pantasys.com>
Subject: Re: [PATCH 2.6] IPCONFIG fix and cleanup
Date: Wed, 08 Sep 2004 17:54:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <413FA9C3.1080007@pantasys.com>
References: <413FA726.7070006@pantasys.com> <20040908174800.11adc930.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060109070003080605060709"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040908174800.11adc930.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060109070003080605060709
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

> Peter, how are you generating your patches?  They never apply
> cleanly.  Maybe Mozilla is messing it up, who knows.  Perhaps
> try using attachments instead.

sorry, try this attachment instead. when i get sendmail configured 
properly i'll use mutt instead ;-)

peter

--------------060109070003080605060709
Content-Type: text/plain;
 name="p"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="p"

--- linus-2.6/net/ipv4/ipconfig.c	2004-09-08 17:35:56.000000000 -0700
+++ local_linux/net/ipv4/ipconfig.c	2004-09-07 17:16:55.000000000 -0700
@@ -966,9 +966,7 @@ static int __init ic_bootp_recv(struct s
 				break;
 
 			case DHCPACK:
-				for (i = 0; (dev->dev_addr[i] == b->hw_addr[i])
-						&& (i < dev->addr_len); i++);
-				if (i < dev->addr_len)
+				if (memcmp(dev->dev_addr, b->hw_addr, dev->addr_len) != 0)
 					goto drop_unlock;
 
 				/* Yeah! */

--------------060109070003080605060709--
