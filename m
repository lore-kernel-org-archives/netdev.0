From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH RFC 1/5] net:stmmac: set threshold/store and forward mode
 according to mtu size.
Date: Mon, 21 Oct 2013 15:49:11 +0200
Message-ID: <526530D7.1090607@st.com>
References: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com> <1381937052-8999-2-git-send-email-jimmy.perchet@parrot.com> <5264EA04.1040002@st.com> <CAJ3bTp62KZVK22b3M5n03Bj20auaUFYDJk-_-U=cDxb2x9dFVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jimmy Perchet <jimmy.perchet@parrot.com>,
	netdev <netdev@vger.kernel.org>
To: Rayagond K <rayagond@vayavyalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:40730 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752626Ab3JUNt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 09:49:28 -0400
In-Reply-To: <CAJ3bTp62KZVK22b3M5n03Bj20auaUFYDJk-_-U=cDxb2x9dFVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/21/2013 11:58 AM, Rayagond K wrote:
> On Mon, Oct 21, 2013 at 2:17 PM, Giuseppe CAVALLARO
> <peppe.cavallaro@st.com>  wrote:
>> >On 10/16/2013 5:24 PM, Jimmy Perchet wrote:
>>> >>
>>> >>Threshold mode dma is needed on rx path if jumbo frames are expected.
>> >
>> >
>> >I think we should not force the threshold mode depending on the mtu.
> I remember SNPS HW team suggesting me to program the rx path in
> Threshold mode for jumbo frames, as it takes care of low RX FIFO size.
>

ok. no problem to keep it as default in the stmmac.

Cheers
Peppe
