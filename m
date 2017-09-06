From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH v2 rfc 0/8] IGMP snooping for local traffic
Date: Wed, 6 Sep 2017 16:27:05 +0200
Message-ID: <2c1d26b4-fbb2-3346-ca35-86b4f635b60a@phrozen.org>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
 <20170906004703.GB27385@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Woojung.Huh@microchip.com, jbe@pengutronix.de,
        sean.wang@mediatek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:59840 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932260AbdIFO1n (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 10:27:43 -0400
In-Reply-To: <20170906004703.GB27385@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/09/17 02:47, Andrew Lunn wrote:
> Should this be done at the DSA level, or at the driver level?  Do any
> chips do broadcast flooding in hardware already? Hence they currently
> see broadcast duplication? If i add a broadcast mdb at the DSA level,
> and the chip is already hard wired to flooding broadcast, is it going
> to double flood?

Hi Andrew,

MT7530 and QCA8K only have a  "unknown mac fwd to port X" feature. both 
use the same HW table for FDB and MDB tables. so this should ideally be 
fixed on DSA level rather than fixing up those 2 drivers.

     John
