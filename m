From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH v3] brcmfmac: avoid duplicated suspend/resume operation
Date: Tue, 3 Mar 2015 20:49:16 +0100
Message-ID: <54F6103C.5090108@broadcom.com>
References: <54DC1D7D.5050407@linux.intel.com>	<54E0072D.3020802@linux.intel.com> <54E01209.7010300@erley.org>	<54E05961.7000201@broadcom.com>	<878ufzi5s3.fsf@kamboji.qca.qualcomm.com>	<54E19DA1.4030407@linux.intel.com> <54E1B9F4.6090302@broadcom.com>	<54F02271.5070202@linux.intel.com> <54F03412.2050902@broadcom.com> <874mq3bfnu.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Fu, Zhonghui" <zhonghui.fu@linux.intel.com>,
	Pat Erley <pat-lkml@erley.org>, <brudley@broadcom.com>,
	Franky Lin <frankyl@broadcom.com>, <meuleman@broadcom.com>,
	<linville@tuxdriver.com>, <pieterpg@broadcom.com>,
	<hdegoede@redhat.com>, <wens@csie.org>,
	<linux-wireless@vger.kernel.org>,
	<brcm80211-dev-list@broadcom.com>, <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <874mq3bfnu.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/02/15 16:08, Kalle Valo wrote:
> Arend van Spriel<arend@broadcom.com>  writes:
>
>>> Now that there is not 3.20 version. My understanding is that this
>>> patch will be in linus' tree 4.1-rc1, right?
>>
>> Yes. It will go into linux-next first, which you can consider to be an
>> incubator where all stuff for the next release is integrated. Stuff
>> will be added there until 4.0 is released. At that moment the merge
>> window starts which moves all the stuff from linux-next into the
>> mainline linux repo to prepare 4.1-rc1.
>>
>> Now regarding your patch I have to give a heads up. Our pending
>> patches have been applied by Kalle and includes similar fix.
>
> Yeah, Zhonghui's patch doesn't apply anymore. There is similar code in
> wireless-drivers-next but still a bit different. So what should we do?
> Is the driver ok now?

The idea of Zhonghui's patch was to avoid entering suspend and resume 
callbacks twice. The current behavior is same as his patch intended so 
yes the driver is ok (pending undiscovered bugs :-p ).

Regards,
Arend
