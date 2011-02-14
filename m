From: "Subhasish Ghosh" <subhasish@mistralsolutions.com>
Subject: Re: [PATCH v2 09/13] can: pruss CAN driver.
Date: Mon, 14 Feb 2011 10:24:48 +0530
Message-ID: <C1C4300CE90A406FBDA2388D5491FAD5@subhasishg>
References: <1297435892-28278-1-git-send-email-subhasish@mistralsolutions.com> <1297435892-28278-10-git-send-email-subhasish@mistralsolutions.com> <20110211150602.GB373@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="UTF-8";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <davinci-linux-open-source@linux.davincidsp.com>,
	<linux-arm-kernel@lists.infradead.org>, <m-watkins@ti.com>,
	<nsekhar@ti.com>, <sachi@mistralsolutions.com>,
	"Wolfgang Grandegger" <wg@grandegger.com>,
	"open list:CAN NETWORK DRIVERS" <socketcan-core@lists.berlios.de>,
	"open list:CAN NETWORK DRIVERS" <netdev@vger.kernel.org>,
	"open list" <linux-kernel@vger.kernel.org>
To: "Kurt Van Dijck" <kurt.van.dijck@eia.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110211150602.GB373@e-circ.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I had a discussion regarding this with Wolfgang:

http://www.mail-archive.com/socketcan-users@lists.berlios.de/msg00324.html

The problem here is that we must configure the mailbox ID's and this support 
is not available in the socketCan sub-system.

--------------------------------------------------
From: "Kurt Van Dijck" <kurt.van.dijck@eia.be>
Sent: Friday, February 11, 2011 8:36 PM
To: "Subhasish Ghosh" <subhasish@mistralsolutions.com>
Cc: <davinci-linux-open-source@linux.davincidsp.com>; 
<linux-arm-kernel@lists.infradead.org>; <m-watkins@ti.com>; 
<nsekhar@ti.com>; <sachi@mistralsolutions.com>; "Wolfgang Grandegger" 
<wg@grandegger.com>; "open list:CAN NETWORK DRIVERS" 
<socketcan-core@lists.berlios.de>; "open list:CAN NETWORK DRIVERS" 
<netdev@vger.kernel.org>; "open list" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2 09/13] can: pruss CAN driver.

> On Fri, Feb 11, 2011 at 08:21:28PM +0530, Subhasish Ghosh wrote:
>> +config DA8XX_PRU_CANID_MBX0
>> + hex "CANID for mailbox 0"
>> + depends on CAN_TI_DA8XX_PRU
>> + default "0x123"
>> + ---help---
>> + Enter the CANID for mailbox 0
>> + Default value is set to 0x123, change this as required.
>> +
>> +config DA8XX_PRU_CANID_MBX1
>> + hex "CANID for mailbox 1"
>> + depends on CAN_TI_DA8XX_PRU
>> + default "0x123"
>> + ---help---
>> + Enter the CANID for mailbox 1
>> + Default value is set to 0x123, change this as required.
>> +
>> +config DA8XX_PRU_CANID_MBX2
>> + hex "CANID for mailbox 2"
>> + depends on CAN_TI_DA8XX_PRU
>> + default "0x123"
>> + ---help---
>> + Enter the CANID for mailbox 2
>> + Default value is set to 0x123, change this as required.
>> +
>> +config DA8XX_PRU_CANID_MBX3
>> + hex "CANID for mailbox 3"
>> + depends on CAN_TI_DA8XX_PRU
>> + default "0x123"
>> + ---help---
>> + Enter the CANID for mailbox 3
>> + Default value is set to 0x123, change this as required.
>> +
>> +config DA8XX_PRU_CANID_MBX4
>> + hex "CANID for mailbox 4"
>> + depends on CAN_TI_DA8XX_PRU
>> + default "0x123"
>> + ---help---
>> + Enter the CANID for mailbox 4
>> + Default value is set to 0x123, change this as required.
>> +
>> +config DA8XX_PRU_CANID_MBX5
>> + hex "CANID for mailbox 5"
>> + depends on CAN_TI_DA8XX_PRU
>> + default "0x123"
>> + ---help---
>> + Enter the CANID for mailbox 5
>> + Default value is set to 0x123, change this as required.
>> +
>> +config DA8XX_PRU_CANID_MBX6
>> + hex "CANID for mailbox 6"
>> + depends on CAN_TI_DA8XX_PRU
>> + default "0x123"
>> + ---help---
>> + Enter the CANID for mailbox 6
>> + Default value is set to 0x123, change this as required.
>> +
>> +config DA8XX_PRU_CANID_MBX7
>> + hex "CANID for mailbox 7"
>> + depends on CAN_TI_DA8XX_PRU
>> + default "0x123"
>> + ---help---
>> + Enter the CANID for mailbox 7
>> + Default value is set to 0x123, change this as required.
> Why is filling the mailboxes the job of kernel config?
>
> Regards,
> Kurt 
