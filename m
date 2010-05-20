From: Rick Jones <rick.jones2@hp.com>
Subject: Re: bnx2x + SFP+ DA/2.6.33.3: Got bad status 0x0 when reading from
 SFP+ EEPROM -> SFP+ module is not initialized
Date: Thu, 20 May 2010 13:25:31 -0700
Message-ID: <4BF59ABB.9070600@hp.com>
References: <4BF56CA6.8080306@ans.pl>	<1274377770.28702.4.camel@lb-tlvb-eilong.il.broadcom.com>	<4BF57ADF.1060203@ans.pl>	<1274381113.28702.6.camel@lb-tlvb-eilong.il.broadcom.com> <4BF59058.6050205@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:8150 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754423Ab0ETU0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 16:26:24 -0400
In-Reply-To: <4BF59058.6050205@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some simple/simplistic thoughts/questions...

Has the DAC been used successfully prior to this?

Do you have another HP ProCurve 10-GbE SFP+ 7m Direct Attach Cable (J9285B) to try?

There's a transceiver and presumably an EEPROM at both ends of a DAC right?  If 
the EEPROM at one end were "bad" might the 57711 be happier with the other end 
of the DAC?  Getting some sort of error message at the switch side, which may 
(or may not) have more detailed diagnostics might help.

rick jones
