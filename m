From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH] add %pM printf format specifier
Date: Sun, 26 Oct 2008 12:38:49 -0700
Message-ID: <1225049929.10060.11.camel@brick>
References: <1224892008.3919.27.camel@johannes.berg>
	 <49035AF0.6040700@anduras.de> <1225008096.3478.3.camel@johannes.berg>
	 <20081026.010329.11475786.davem@davemloft.net>
	 <1225009308.3478.22.camel@johannes.berg>
	 <1225009822.3478.30.camel@johannes.berg>  <1225047674.10060.10.camel@brick>
	 (sfid-20081026_200122_320043_BFBB81CD)  <1225049591.3746.0.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, anders@anduras.de,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:5332 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751602AbYJZTiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 15:38:52 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1781574rvb.1
        for <netdev@vger.kernel.org>; Sun, 26 Oct 2008 12:38:52 -0700 (PDT)
In-Reply-To: <1225049591.3746.0.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-10-26 at 20:33 +0100, Johannes Berg wrote:
> On Sun, 2008-10-26 at 12:01 -0700, Harvey Harrison wrote:
> > On Sun, 2008-10-26 at 09:30 +0100, Johannes Berg wrote:
> > > static char *ip6_string(char *buf, char *end, be16 *addr, int field_width, int precision, int flags)
> > > {
> > > 	char ip6[8*5];
> > > 	char *p = ip6;
> > > 	int i;
> > > 	u16 tmp;
> > > 
> > > 	for (i=0; i<7; i++) {
> > > 		tmp = cpu_to_le16(addr[i]);
> > 
> > 		tmp = be16_to_cpup(addr + i);
> > 
> > > 		p = pack_hex_byte(p, tmp >> 8);
> > > 		p = pack_hex_byte(p, tmp & 0xFF);
> > > 		if (!(flags & SPECIAL))
> > > 			*p++ = ':';
> > > 	}
> > > 	tmp = cpu_to_le16(addr[7]);
> > 
> > 	tmp = be16_to_cpup(addr + 7);
> > 
> > Or maybe just cast addr to char * and avoid the byteswapping altogether.
> 
> Yeah, this was obviously not tested. Want to build it? I don't have
> access to a fast build machine right now.
> 

Could you send me whatever you've got currently and I'll have a go at
it.

Cheers,

Harvey

