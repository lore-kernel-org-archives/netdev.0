From: Kenzo Iwami <k-iwami@cj.jp.nec.com>
Subject: Re: watchdog timeout panic in e1000 driver
Date: Tue, 24 Oct 2006 18:01:44 +0900
Message-ID: <453DD678.4010606@cj.jp.nec.com>
References: <45375135.5050206@cj.jp.nec.com> <45379C14.5050901@foo-projects.org> <4538BFF2.2040207@cj.jp.nec.com> <4538F080.5020003@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:21944 "EHLO
	tyo201.gate.nec.co.jp") by vger.kernel.org with ESMTP
	id S1030238AbWJXJBv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 05:01:51 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <4538F080.5020003@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Thank you for your comment.

> This panic report falls in the category "how hard can I break my system as root". 
> Explicitly abusing the system performing restricted calls depletes resources and 
> harasses the sw lock (in this case). The reason that the driver attempts to wait that 
> long is that in the case of ESB2 systems, the SPI interface to the EEPROM can be slow, 
> thus taking a long time to complete certain commands.

This problem originally occurred in a very large cluster system using snmp
for server management. About two servers panicked each day. The program I sent
is to reproduce this problem in a very short time. It does occur under normal
load when there is a lot of servers.

-- 
  Kenzo Iwami (k-iwami@cj.jp.nec.com)
