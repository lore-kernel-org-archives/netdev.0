From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/2] r8169: checks against wrong mac addresse init
Date: Fri, 17 Oct 2008 22:01:14 +0200
Message-ID: <20081017200114.GA25222@electric-eye.fr.zoreil.com>
References: <20081016214555.GA27208@electric-eye.fr.zoreil.com> <20081016214808.GC27208@electric-eye.fr.zoreil.com> <1224265672.17605.27.camel@marvin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jeff@garzik.org, Edward Hsu <edward_hsu@realtek.com.tw>,
	Ivan Vecera <ivecera@redhat.com>,
	Petr Vandrovec <petr@vandrovec.name>,
	Plamen Petrov <pvp-lsts@fs.ru.acad.bg>,
	=?unknown-8bit?B?Si5BLiBNYWdhbGzDs24=?= <jamagallon@ono.com>
To: Martin Capitanio <c4p7n@capitanio.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39174 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756450AbYJQUCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 16:02:32 -0400
Content-Disposition: inline
In-Reply-To: <1224265672.17605.27.camel@marvin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Martin Capitanio <c4p7n@capitanio.org> :
[...]
> Please take a look at the realtek r8101_n aka RealTek RTL8101E,
> RTL8102E(L) code. Only CFG_METHOD_1, CFG_METHOD_2
> and #(ioaddr, 0x00) == 0x8128 are here allowed to EEPROM access.

So Realtek's 810x driver eeprom code targets the 8101Eb and the
8101Ec only. It does not include Ivan's 8102el.

[...]
> static void
> rtl8101_check_eeprom(struct rtl8101_private *tp)
> {
[...]
> 	mac_addr_1 = rtl_eeprom_read_sc(ioaddr, 0x08);
> 	mac_addr_1 = mac_addr_1 << 16;
> 
> 	mac_addr_2 = rtl_eeprom_read_sc(ioaddr, 0x07);
> 	mac_addr_1 |= mac_addr_2;

The mac address is at the usual place.

-- 
Ueimor
