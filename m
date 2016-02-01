From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] mac80211: fix memory leak
Date: Mon, 1 Feb 2016 15:57:09 +0300
Message-ID: <56AF5625.5030701@cogentembedded.com>
References: <1454060944-11320-1-git-send-email-sudipm.mukherjee@gmail.com>
 <CAGRGNgXc9PtYY=hb8nNRt4T5YGm2vexcJ01Z1fCCcb=57WRZ3g@mail.gmail.com>
 <20160201042548.GA4072@sudip-pc> <878u34u6d6.fsf@purkki.adurom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Julian Calaby <julian.calaby@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Kalle Valo <kvalo@codeaurora.org>,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:34838 "EHLO
	mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932101AbcBAM5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 07:57:12 -0500
Received: by mail-lf0-f43.google.com with SMTP id l143so28480685lfe.2
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 04:57:12 -0800 (PST)
In-Reply-To: <878u34u6d6.fsf@purkki.adurom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/1/2016 12:28 PM, Kalle Valo wrote:

>> On Mon, Feb 01, 2016 at 11:03:35AM +1100, Julian Calaby wrote:
>>> Hi Sudip,
>>>
>>> On Fri, Jan 29, 2016 at 8:49 PM, Sudip Mukherjee
>>> <sudipm.mukherjee@gmail.com> wrote:
>>>> On error we jumped to the error label and returned the error code but we
>>>> missed releasing sinfo.
>>>>
>>>> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
>>>
>>> Should the From: and Signed-off-by: email addresses be the same?
>>
>> I think 2 years back I had a long discussion with Greg about this and
>> since then I al submitting patches like this. A small summayg of the
>> problem from that discussion:
>>
>> "we have strict DMARC check for the corporate mail server. DMARC =
>> domain based message authentication.
>> So the mail i sent reached all the list subscriber from a different
>> server than our designated server, and as a result it is marked as spam
>> in many places and I have already received a few complaints regarding
>> that."
>
> You can add a separate "From:" line to the beginning of the commit log
> and git will use it then commiting the patch. I didn't find any
> documention but it's easy to do and should solve this.

    Documentation/SubmittingPatches, clause 14.

MBR, Sergei
