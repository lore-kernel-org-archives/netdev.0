From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: stmmac/RTL8211F/Meson GXBB: TX throughput problems
Date: Mon, 19 Sep 2016 07:38:18 +0200
Message-ID: <22bfe293-02b0-e7f6-b11f-9d7a51d23a79@st.com>
References: <CAFBinCALSL_-izJ2tEsAjevAw90kGNTrQ3na3D1YV8f1dS1=Xg@mail.gmail.com>
 <ce15ad26-2d07-655d-b813-947ad86696ac@st.com>
 <20160918224240.0bf5a9ed@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        <netdev@vger.kernel.org>, <linux-amlogic@lists.infradead.org>,
        Alexandre Torgue <alexandre.torgue@st.com>
To: =?UTF-8?Q?Andr=c3=a9_Roth?= <neolynx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:50762 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755785AbcISFiv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 01:38:51 -0400
In-Reply-To: <20160918224240.0bf5a9ed@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello André

On 9/18/2016 10:42 PM, André Roth wrote:
>
> Hello,
>
>> For example, you could try disabling the scatter-gather or tx-cum
>> via ethtool and seeing if there is some benefit; so we could image
>> some problem on your HW or SYNP MAC integration for checksumming
>> on tx side.
>
> disabling the following:
>   ethtool -K eth0 sg off
> or:
>   ethtool -K eth0 tx off
> does not prevent the network communication going down..
>
>> Also you could check the AXI tuning and PBL value. To be honest
>> (thinking about your problem) I can actually suspect some related
>> problem on bus setup. So I suggest you to play with these value
>> (better if you ask for having values from HW validation on your side).
>> Otherwise the stmmac uses a default that cannot be good for your
>> platform. For example, sometime I have seen that PBL is better if
>> reduced to 8 instead of 32 and w/o 4xPBL...
>
> how can I set those values ?
>
> thanks for your time,

welcome

take a look at Documentation/devicetree/bindings/net/stmmac.txt

peppe

>
>  andre
>
>
