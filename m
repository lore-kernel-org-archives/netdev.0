From: Sekhar Nori <nsekhar@ti.com>
Subject: Re: [PATCH v3 0/6] ARM: davinci: da850: add ethernet driver DT support
Date: Fri, 12 Jul 2013 12:21:20 +0530
Message-ID: <51DFA768.9090703@ti.com>
References: <1371999607-6483-1-git-send-email-prabhakar.csengg@gmail.com>
 <CA+V-a8t-sTPAK+D5869X0_ZCdrmK0B+eRaowk9hMYwXMw09NqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
 DLOS <davinci-linux-open-source@linux.davincidsp.com>,
 devicetree-discuss@lists.ozlabs.org,
 LAK <linux-arm-kernel@lists.infradead.org>,
 LKML <linux-kernel@vger.kernel.org>
To: Prabhakar Lad <prabhakar.csengg@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CA+V-a8t-sTPAK+D5869X0_ZCdrmK0B+eRaowk9hMYwXMw09NqA@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 7/11/2013 10:42 PM, Prabhakar Lad wrote:
> Hi Sekhar,
> 
> On Sun, Jun 23, 2013 at 8:30 PM, Prabhakar Lad
> <prabhakar.csengg@gmail.com> wrote:
>> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
>>
>> This patch set enables Ethernet support through device tree model.
>> This patch set enables mii interface only and is being tested to boot via
>> rootfs. The rmii phy is present on the i2c gpio expander chip (UI board)
>> for which yet support needs to be added, once the DT support for the chip
>> is enabled, enabling rmii will be subsequnet patch.
>>
>> Changes for v2:
>> 1: Enabled mdio device.
>> 2: Fixed clock lookup.
>>
>> Changes for v3:
>> 1: Fixed review comments pointed out by Sekhar.
>>
>> Lad, Prabhakar (6):
>>   ARM: davinci: da8xx: fix clock lookup for mdio device
>>   ARM: davinci: da850: add DT node for mdio device
>>   ARM: davinci: da850: add OF_DEV_AUXDATA entry for mdio.
>>   ARM: davinci: da850: add DT node for eth0.
>>   ARM: davinci: da850: add OF_DEV_AUXDATA entry for eth0.
>>   ARM: davinci: da850: configure system configuration chip(CFGCHIP3)
>>     for emac
>>
> gentle ping..

I haven't been able to get to reviewing patches meant for v3.12 yet.
Most probably will happen next week.

Thanks,
Sekhar
