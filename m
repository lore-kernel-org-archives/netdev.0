From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 07:41:01 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200306101142.h5ABgssG004210@ginger.cmf.nrl.navy.mil>
References: <20030610061010.Y36963@shell.cyberus.ca>
Cc: ralph+d@istop.com, CIT/Paul <xerox@foonet.net>,
   "'Simon Kirby'" <sim@netnation.com>, "'David S. Miller'" <davem@redhat.com>,
   "fw@deneb.enyo.de" <fw@deneb.enyo.de>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
   "linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi <hadi@shell.cyberus.ca>
In-reply-to: Your message of "Tue, 10 Jun 2003 06:53:04 EDT."
             <20030610061010.Y36963@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030610061010.Y36963@shell.cyberus.ca>,Jamal Hadi writes:
>is we actually test on real environments or maybe even collect real
>world traffic patterns and run them in the lab.
>Typically, real world is less intense than the lab. Ex: noone sends
>100Mbps at 64 byte packet size. Typical packet is around 500 bytes
>average. If linux can handle that forwarding capacity, it should easily

i was curious at one point and collected a some packet size stats on
our border router.  while the average packet size is close to 500,
the bulk (by count) of the traffic seems to be in the 64-95 byte range.
(the length here is the link level size as given by tcpdump -e)

# 27100000 packets  average length = 747
0-31 5271
32-63 0
64-95 12143442
96-127 934314
128-159 202984
160-191 98772
192-223 49279
224-255 37826
256-287 28276
288-319 41675
320-351 42359
352-383 93709
384-415 24557
416-447 73969
448-479 25100
480-511 23210
512-543 86515
544-575 77779
576-607 146066
608-639 23967
640-671 23005
672-703 87471
704-735 13154
736-767 8818
768-799 20850
800-831 7678
832-863 7379
864-895 7920
896-927 5789
928-959 48122
960-991 35512
992-1023 26081
1024-1055 63541
1056-1087 23673
1088-1119 8397
1120-1151 5780
1152-1183 5133
1184-1215 8820
1216-1247 40251
1248-1279 6295
1280-1311 11420
1312-1343 31610
1344-1375 21802
1376-1407 22442
1408-1439 4932071
1440-1471 594385
1472-1503 439460
1504-1535 6434071
