From: Jeff Garzik <jgarzik@pobox.com>
Subject: ethtool_features?
Date: Wed, 27 Aug 2003 18:22:35 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F4D2F2B.2090401@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Maillist netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hum.  Instead of adding all these _get_foo ops to test dev->features 
bits, would anyone mind if I created a single _get_features() ethtool 
sub-ioctl?

Given the current ethtool_ops code, its implementation would in fact be 
completely transparent to low-level drivers.  It need only be 
implemented in net/core/ethtool.c, without even adding a new hook.

	Jeff
