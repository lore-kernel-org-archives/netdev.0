From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] mac80211: fix memory leak
Date: Mon, 01 Feb 2016 11:28:37 +0200
Message-ID: <878u34u6d6.fsf@purkki.adurom.net>
References: <1454060944-11320-1-git-send-email-sudipm.mukherjee@gmail.com>
	<CAGRGNgXc9PtYY=hb8nNRt4T5YGm2vexcJ01Z1fCCcb=57WRZ3g@mail.gmail.com>
	<20160201042548.GA4072@sudip-pc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julian Calaby <julian.calaby@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160201042548.GA4072@sudip-pc> (Sudip Mukherjee's message of
	"Mon, 1 Feb 2016 09:55:48 +0530")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sudip Mukherjee <sudipm.mukherjee@gmail.com> writes:

> On Mon, Feb 01, 2016 at 11:03:35AM +1100, Julian Calaby wrote:
>> Hi Sudip,
>> 
>> On Fri, Jan 29, 2016 at 8:49 PM, Sudip Mukherjee
>> <sudipm.mukherjee@gmail.com> wrote:
>> > On error we jumped to the error label and returned the error code but we
>> > missed releasing sinfo.
>> >
>> > Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
>> 
>> Should the From: and Signed-off-by: email addresses be the same?
>
> I think 2 years back I had a long discussion with Greg about this and
> since then I al submitting patches like this. A small summayg of the
> problem from that discussion:
>
> "we have strict DMARC check for the corporate mail server. DMARC =
> domain based message authentication.
> So the mail i sent reached all the list subscriber from a different
> server than our designated server, and as a result it is marked as spam
> in many places and I have already received a few complaints regarding
> that."

You can add a separate "From:" line to the beginning of the commit log
and git will use it then commiting the patch. I didn't find any
documention but it's easy to do and should solve this.

-- 
Kalle Valo
