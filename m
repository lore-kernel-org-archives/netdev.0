From: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] mac80211: fix memory leak
Date: Mon, 1 Feb 2016 15:30:38 +1100
Message-ID: <CAGRGNgUDPiCJqnSzboP6mvNdmW5T74aUfbSRs5SP8HMgZQBFJw@mail.gmail.com>
References: <1454060944-11320-1-git-send-email-sudipm.mukherjee@gmail.com>
 <CAGRGNgXc9PtYY=hb8nNRt4T5YGm2vexcJ01Z1fCCcb=57WRZ3g@mail.gmail.com> <20160201042548.GA4072@sudip-pc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Sudip Mukherjee <sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160201042548.GA4072@sudip-pc>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Sudip,

On Mon, Feb 1, 2016 at 3:25 PM, Sudip Mukherjee
<sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Mon, Feb 01, 2016 at 11:03:35AM +1100, Julian Calaby wrote:
>> Hi Sudip,
>>
>> On Fri, Jan 29, 2016 at 8:49 PM, Sudip Mukherjee
>> <sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> > On error we jumped to the error label and returned the error code but we
>> > missed releasing sinfo.
>> >
>> > Signed-off-by: Sudip Mukherjee <sudip-ofJRbWXBVFamYgehrs7/Lw@public.gmane.org>
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

Ok, fair enough then.

Thanks,

-- 
Julian Calaby

Email: julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Profile: http://www.google.com/profiles/julian.calaby/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
