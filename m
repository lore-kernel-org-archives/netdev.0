From: Masahide Nakamura <nakam@linux-ipv6.org>
Subject: [IPROUTE2] purging a directory
Date: Tue, 3 Aug 2004 16:45:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040803164552.4b5cea87@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, nakam@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Stephen,

I found a ChangeSet which seems to be an erroneous importing
in your iproute2 tree. (That is a patch I sent.)

It causes directory problem; It creates new sub directory
named "iproute2" which should be placed as parent one.

It is unnecessary so please remove it or
try below (it works fine for me in local testing):
	bk -r prs -hr+ -nd:ROOTKEY: | grep '|iproute2' | bk csetprune

Thanks,

-- 
Masahide NAKAMURA
