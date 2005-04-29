From: Asim Shankar <asimshankar@gmail.com>
Subject: [RESEND] [PATCH 2.6.11.7] sch_htb: Drop packet when direct queue is
 full
Date: Fri, 29 Apr 2005 17:33:12 +0000 (UTC)
Message-ID: <Pine.LNX.4.61.0504291725000.28792@limnos.csrd.uiuc.edu>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="2122463882-1702178855-1114795992=:28792"
Cc: davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--2122463882-1702178855-1114795992=:28792
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed

htb_enqueue(): Free skb and return NET_XMIT_DROP if a packet is
destined for the direct_queue but the direct_queue is full. (Before
this: erroneously returned NET_XMIT_SUCCESS even though the packet was
not enqueued)

Signed-off-by: Asim Shankar <asimshankar@gmail.com>
--2122463882-1702178855-1114795992=:28792
Content-Type: APPLICATION/x-gzip; name="patch-htb-2.6.11.7.gz"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.61.0504291733120.28792@limnos.csrd.uiuc.edu>
Content-Description: 
Content-Disposition: attachment; filename="patch-htb-2.6.11.7.gz"

H4sICDdtckIAA3BhdGNoLWh0Yi0yLjYuMTEuNwCNkF9rwjAUxZ/tp7hjMOpi
YlJNO3WIw/1B2HRsPuwt2DadoaXaJoXB8Lsv0cKGT8tDAuee+zucYIyhUGXz
hQMSEsZI1C+l6etkK1N3i62JSUJ2tfrsBJRyTIc4GAELxoyPA0b4cMTDwWB4
A5hySj2E0D9456hwzCmhQcQCzkdhi5rNAEcs6oWA3MMoWEWbjVEJqNKAJQlZ
Vo1spK9N3SQGdC7iJsvgWnvQURn4FZ6mqpaJEUcfqQpZwi38ka3QhW9rB3uE
0Hl8sgqzUYV/dQbo2Yi4O2ntv8N9bjRCEw91DiALLS0RHS15VkvpqP5p8aTa
j8DTynXRJK13+3bXjWppmrqE5cNafLws1uL+bfXq8g4eXKoslRnMV8vHxZNw
jvnzu7ibrz23CG2yq32RFK7UDybStHLdAQAA

--2122463882-1702178855-1114795992=:28792--
