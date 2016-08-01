From: "Levin, Alexander" <alexander.levin@verizon.com>
Subject: Re: [PATCH] net: thunderx: correct bound check in nic_config_loopback
Date: Mon, 1 Aug 2016 11:57:58 -0400
Message-ID: <6b86fd8a-e97a-8b71-1786-50aa9e667873@verizon.com>
References: <1469933384-16827-1-git-send-email-alexander.levin@verizon.com>
 <CA+sq2Cc-MTtoncAcL6MS-YVdeVVK=aqEmZakzkX6_CwsXvpRCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "sgoutham@cavium.com" <sgoutham@cavium.com>,
 "rric@kernel.org" <rric@kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Sunil Kovvuri <sunil.kovvuri@gmail.com>, "Levin, Alexander"
 <alexander.levin@verizon.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CA+sq2Cc-MTtoncAcL6MS-YVdeVVK=aqEmZakzkX6_CwsXvpRCQ@mail.gmail.com>
Content-Language: en-US
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

On 07/31/2016 12:41 PM, Sunil Kovvuri wrote:
> Thanks for finding.
> A much better fix would be,
> 
> -       if (lbk->vf_id > MAX_LMAC)
> +       if (lbk->vf_id >= nic->num_vf_en)
>                 return -1;
> 
> where 'num_vf_en' reflects the exact number of physical interfaces or
> LMACs on the system.

Right. I see quite a few more places that compare to MAX_LMAC vs
num_vf_en. What was the reasoning behind it then?


Thanks,
Sasha
