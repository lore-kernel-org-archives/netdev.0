From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: Re: [PATCH v5 0/5] stmmac: pci: Refactor DMI probing
Date: Thu, 22 Jun 2017 19:43:51 +0200
Message-ID: <5d4f15dc-057c-dbc0-b3cf-27163e4e6347@siemens.com>
References: <cover.1498112281.git.jan.kiszka@siemens.com>
 <20170622.134031.1966602928075071150.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        andy.shevchenko@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170622.134031.1966602928075071150.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-06-22 19:40, David Miller wrote:
> From: Jan Kiszka <jan.kiszka@siemens.com>
> Date: Thu, 22 Jun 2017 08:17:56 +0200
> 
>> Some cleanups of the way we probe DMI platforms in the driver. Reduces
>> a bit of open-coding and makes the logic easier reusable for any
>> potential DMI platform != Quark.
>>
>> Tested on IOT2000 and Galileo Gen2.
>>
>> Changes in v5:
>>  - fixed a remaining issue in patch 5
>>  - dropped patch 6 for now
> 
> Series applied to net-next.
> 
> Any chance the DMI table can be marked const as well?
> 

Hmm, they are all const - or which one do you mean?

Jan

-- 
Siemens AG, Corporate Technology, CT RDA ITP SES-DE
Corporate Competence Center Embedded Linux
