From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 0/4]: Scalable HFSC
Date: Sat, 14 Aug 2004 22:00:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411E6F49.9030303@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, devik <devik@cdi.cz>, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

These 4 patches for 2.4/2.6 make HFSC more scalable by using rbtree's
instead of sorted lists and an O(1) algorithm for adjusting childrens
vt-offset. With these patches HFSC with 1024 active sibling classes
performs only slightly worse (CPU-wise) than HTB. Each change has been
well tested in tcsim, so I think nothing should break.

Regards
Patrick
