From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net.git) 2/4] stmmac: fix and better tune the default
 buffer sizes
Date: Wed, 5 Mar 2014 11:26:10 +0100
Message-ID: <5316FBC2.6060501@st.com>
References: <1393497340-8013-1-git-send-email-peppe.cavallaro@st.com> <1393497340-8013-3-git-send-email-peppe.cavallaro@st.com> <063D6719AE5E284EB5DD2968C1650D6D0F6CC945@AcuExch.aculab.com> <530F3784.5050304@st.com> <063D6719AE5E284EB5DD2968C1650D6D0F6CCBB2@AcuExch.aculab.com> <530F4389.8060309@st.com> <53157ED1.2010505@st.com> <063D6719AE5E284EB5DD2968C1650D6D0F6D14A3@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:38662 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752331AbaCEK0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 05:26:21 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6D14A3@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/5/2014 10:33 AM, David Laight wrote:
> From: Giuseppe CAVALLARO
>> Hello David
>>
>> Sorry, can you tell me what is the final your opinion about
>> this patch?
>>
>> I think that it not good to keep 4KiB as default and your main concern
>> was about the default buffer size that depended on VLAN ifconfig.
>>
>> So I could adopt 1536bytes as default and remove ifdef.
>
> If the rx buffer size has to match the mtu then the minimum
> size needs to be that for non-vlan packets.
>
> OTOH if the rx buffer size only has to be 'long enough' and
> a frame length check is done in software then you can always
> use the vlan length and save reconfig is someone enables vlans.

yes this is what I wanted to have.

> My real concern was that you were setting the minimum buffer
> size based on a vlan config option - which really didn't seem
> right at all.

ok, so I'll re-send a patch using as default 1536 and w/o surrounding
the code with ifdef (vlan).

thx
peppe

>
> 	David
>
>
>
>
>
