From: Kishan Sandeep <sandeepkishan108@gmail.com>
Subject: Re: [PATCH v2] net: stmmac: bug fix to synchronize stmmac_open and stmmac_dvr_probe
Date: Wed, 28 Dec 2016 17:26:03 +0530
Message-ID: <CAJ3s=NAzfUSCnxxZph5j6Vk2T=pw2F9U3FLP7dOKRp21mmQvcg@mail.gmail.com>
References: <1482849756-21817-1-git-send-email-hock.leong.kweh@intel.com>
 <20161227.113405.362102687632949941.davem@davemloft.net> <F54AEECA5E2B9541821D670476DAE19C5A916C0E@PGSMSX102.gar.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "Joao.Pinto@synopsys.com" <Joao.Pinto@synopsys.com>,
        "peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
        "seraphin.bonnaffe@st.com" <seraphin.bonnaffe@st.com>,
        "alexandre.torgue@gmail.com" <alexandre.torgue@gmail.com>,
        "manabian@gmail.com" <manabian@gmail.com>,
        "niklas.cassel@axis.com" <niklas.cassel@axis.com>,
        "johan@kernel.org" <johan@kernel.org>,
        "pavel@ucw.cz" <pavel@ucw.cz>,
        "lars.persson@axis.com" <lars.persson@axis.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <F54AEECA5E2B9541821D670476DAE19C5A916C0E@PGSMSX102.gar.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 28, 2016 at 7:10 AM, Kweh, Hock Leong
<hock.leong.kweh@intel.com> wrote:
>> -----Original Message-----
>> From: David Miller [mailto:davem@davemloft.net]
>> Sent: Wednesday, December 28, 2016 12:34 AM
>> To: Kweh, Hock Leong <hock.leong.kweh@intel.com>
>> Cc: Joao.Pinto@synopsys.com; peppe.cavallaro@st.com;
>> seraphin.bonnaffe@st.com; f.fainelli@gmail.com;
>> alexandre.torgue@gmail.com; manabian@gmail.com; niklas.cassel@axis.com;
>> johan@kernel.org; pavel@ucw.cz; Ong, Boon Leong
>> <boon.leong.ong@intel.com>; Voon, Weifeng <weifeng.voon@intel.com>;
>> lars.persson@axis.com; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
>> Subject: Re: [PATCH v2] net: stmmac: bug fix to synchronize stmmac_open and
>> stmmac_dvr_probe
>>
>> From: "Kweh, Hock Leong"      <hock.leong.kweh@intel.com>
>> Date: Tue, 27 Dec 2016 22:42:36 +0800
>>
>> > From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
>>
>> You are not the author of this change, do not take credit for it.
>>
>> You have copied Florian's patch character by character, therefore
>> he is the author.
>>
>> You also didn't CC: the netdev mailing list properly.
>
> Noted & Thanks.
>
> Hi Florian, could you submit this fix from your side so that you are the author.
> I will help to test out.
>
> Thanks & Regards,
> Wilson
>
I think you can give *--author* for giving author name. Try git commit
-am "commit message" --author="Author_name <author_email>"
