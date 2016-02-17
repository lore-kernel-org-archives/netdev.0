From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH] net: ti: netcp: restore get/set_pad_info() functionality
Date: Wed, 17 Feb 2016 11:19:57 -0500
Message-ID: <56C49DAD.8050901@ti.com>
References: <1455026303-17014-1-git-send-email-grygorii.strashko@ti.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCDC216@AcuExch.aculab.com>
 <3E54258959B69E4282D79E01AB1F32B704D12E49@DFLE11.ent.ti.com>
 <4072312.pCFuaqSbhC@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@aculab.com>,
	"Strashko, Grygorii" <grygorii.strashko@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S . Miller" <davem@davemloft.net>,
	"Cooper Jr., Franklin" <fcooper@ti.com>,
	"Nori, Sekhar" <nsekhar@ti.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Kwok, WingMan" <w-kwok2@ti.com>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4072312.pCFuaqSbhC@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/09/2016 02:38 PM, Arnd Bergmann wrote:
> On Tuesday 09 February 2016 16:55:42 Karicheri, Muralidharan wrote:
>> The descriptors are usable by different drivers, one driver may use it as 
>> buf ptr/ len, other for something else. So they should remain as generic
>> and it is up to individual drivers to use it in whatever way it requires.
>> My suggestion is to rename pad field in struct knav_dma_desc to sw_data
>> to avoid confusion. i.e 
>>
>> +       __le32  pad[4];
>>
>> to 
>>
>> +       __le32  sw_data[4];
>>
> If the hardware doesn't access them, they can probably just be u32
> and not do any byte swapping.
Agree.
>
> 	Arnd
>


-- 
Murali Karicheri
Linux Kernel, Keystone
