From: "Eble, Dan" <DanE@aiinet.com>
Subject: RE: [PATCH] get_random_bytes returns the same on every boot
Date: Mon, 26 Jul 2004 09:57:10 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C0170D0AF1277849A4B4518034F855DD0CFC2F@aiexchange.ai.aiinet.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Balint Marton" <cus@fazekas.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Balint Marton wrote:
> At boot time, get_random_bytes always returns the same 
> random data, as if there were a constant random seed.
> packet with always the same transaction ID. (If you have 
> more than one computers, and they are booting at the
> same time, then this is a big problem)

If many systems are booting at the same time, is seeding with the system
time really an appropriate solution?  Shouldn't some system-specific
value also contribute to the randomization?
