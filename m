From: Michael Trimarchi <trimarchi@gandalf.sssup.it>
Subject: Re: dm9000: add set_mac_address() v2
Date: Mon, 13 Aug 2007 00:45:17 +0200
Message-ID: <46BF8D7D.5070105@gandalf.sssup.it>
References: <20070812192741.GB27490@gandalf.sssup.it> <200708122338.08523.mb@bu3sch.de> <20070812212009.GD27490@gandalf.sssup.it> <200708130026.07221.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms01.sssup.it ([193.205.80.99]:36102 "EHLO sssup.it"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1764985AbXHLWpY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2007 18:45:24 -0400
In-Reply-To: <200708130026.07221.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>> +		return -EBUSY;
>> +
>> +	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
>> +
>> +	for (i = 0; i < 3; i++)
>> +		write_srom_word(db, i,
>> +				cpu_to_le16(((u16 *) (addr->sa_data))[i]));
>>     
>
> Nope.
>
> write_srom_word(db, i, le16_to_cpu(((__le16 *) (addr->sa_data))[i]));
>
>   
Are you sure? I don't know how the dm9000 reads the eeprom back.

regards
Michael

