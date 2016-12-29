From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] net: stmmac: bug fix to synchronize stmmac_open and
 stmmac_dvr_probe
Date: Wed, 28 Dec 2016 16:40:17 -0800
Message-ID: <5939e711-ac50-3a25-fd35-cd427f44663e@gmail.com>
References: <1482849756-21817-1-git-send-email-hock.leong.kweh@intel.com>
 <20161227.113405.362102687632949941.davem@davemloft.net>
 <F54AEECA5E2B9541821D670476DAE19C5A916CA0@PGSMSX102.gar.corp.intel.com>
 <e88996a8-e010-c07f-7dee-d220a6dfc706@gmail.com>
 <F54AEECA5E2B9541821D670476DAE19C5A916EB3@PGSMSX102.gar.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Joao.Pinto@synopsys.com" <Joao.Pinto@synopsys.com>,
        "peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
        "seraphin.bonnaffe@st.com" <seraphin.bonnaffe@st.com>,
        "alexandre.torgue@gmail.com" <alexandre.torgue@gmail.com>,
        "manabian@gmail.com" <manabian@gmail.com>,
        "niklas.cassel@axis.com" <niklas.cassel@axis.com>,
        "johan@kernel.org" <johan@kernel.org>,
        "pavel@ucw.cz" <pavel@ucw.cz>,
        "Ong, Boon Leong" <boon.leong.ong@intel.com>,
        "Voon, Weifeng" <weifeng.voon@intel.com>,
        "lars.persson@axis.com" <lars.persson@axis.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <F54AEECA5E2B9541821D670476DAE19C5A916EB3@PGSMSX102.gar.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/28/2016 04:28 PM, Kweh, Hock Leong wrote:
>> Although this is required, we can't be doing it in all circumstances, we need to
>> mimic what stmmac_drv_remove() does.
>>
>> Let me submit an incremental fix which takes care of mdio bus unregistration.
>> --
>> Florian
> 
> Noted & Thanks. Will test it out once you submitted.

It's done:

https://www.spinics.net/lists/netdev/msg411934.html
-- 
Florian
