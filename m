From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: Re: [PATCH v2 6/6] stmmac: pci: Remove setup handler indirection via
 stmmac_pci_info
Date: Sun, 28 May 2017 18:52:32 +0200
Message-ID: <70fc470e-52e5-cf7d-6003-5e487dfe73f7@siemens.com>
References: <cover.1495814872.git.jan.kiszka@siemens.com>
 <6183ce221f01384f4d50b0cfd62beabe337f5b39.1495814872.git.jan.kiszka@siemens.com>
 <CAHp75Vd299jy+4pBUnbbA-2dRL5L=P5jCDtq+WC06WZjdWynRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from thoth.sbs.de ([192.35.17.2]:40425 "EHLO thoth.sbs.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750791AbdE1Qwk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 28 May 2017 12:52:40 -0400
In-Reply-To: <CAHp75Vd299jy+4pBUnbbA-2dRL5L=P5jCDtq+WC06WZjdWynRw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-05-27 15:38, Andy Shevchenko wrote:
> On Fri, May 26, 2017 at 7:07 PM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
>> By now, stmmac_pci_info only contains a single entry.
> 
> _For now_.
> 
>> Register this
>> directly with the PCI device table, removing one indirection.
> 
> I am not sure this patch is needed.
> 
> Next time something comes up we would need to extend this and
> effectively revert this change.
> So, my vote is to leave it as is for now.

Therefore moved this to the end: may the maintainer pick it or not.

Jan

-- 
Siemens AG, Corporate Technology, CT RDA ITP SES-DE
Corporate Competence Center Embedded Linux
