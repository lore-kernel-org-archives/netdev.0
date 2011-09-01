From: Jiri Slaby <jirislaby@gmail.com>
Subject: [next] unix stream crashes
Date: Thu, 01 Sep 2011 22:46:32 +0200
Message-ID: <4E5FEF28.60406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	ML netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: tim.c.chen@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

my box 100% crashes when booting. It's both in unix socket recv and send 
paths. I've reverted 0856a30409 (Scm: Remove unnecessary pid & 
credential references in Unix socket's send and receive path) and it 
seems to help.

The oops:
http://www.fi.muni.cz/~xslaby/sklad/panics/af_unix_crash.png

regards,
-- 
js
