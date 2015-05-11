From: Okash Khawaja <okash.khawaja-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] adm8211: fix the possible pci cache line sizes inside switch-case
Date: Mon, 11 May 2015 18:48:11 +0100
Message-ID: <4C95B6D2-3A68-4360-BE3C-5264DD0ED8DF@gmail.com>
References: <20150505224020.GA3805@bytefire-computer> <87wq0ms3mv.fsf@kamboji.qca.qualcomm.com> <20150506063241.GA3042@bytefire-computer> <87k2wflj7p.fsf@kamboji.qca.qualcomm.com> <2CBE2DDF-92E5-45C9-95F8-C5CF918D12D9@gmail.com> <87vbfzjt4t.fsf@kamboji.qca.qualcomm.com> <CAOiHx=kzSsFenqPSNeAX6P5wJK8Hr-q+s+rJoQQMPbSGmE50xw@mail.gmail.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org" <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jonas Gorski <jogo-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAOiHx=kzSsFenqPSNeAX6P5wJK8Hr-q+s+rJoQQMPbSGmE50xw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> On 11 May 2015, at 14:24, Jonas Gorski <jogo-p3rKhJxN3npAfugRpC6u6w@public.gmane.org> wrote:
> 
> Hi,
> 
>> On Mon, May 11, 2015 at 12:38 PM, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> wrote:
>> Okash Khawaja <okash.khawaja-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>> 
>>> Sure, I'll create v2 of the patch with updated commit log.
>>> 
>>> Since it's part of a patch set, do you want me to send both the
>>> patches in the patch set together as v2 or just this patch?
>> 
>> Please resend the whole patchset as v2, less problems that way.
> 
> If you are sending a v2 anyway, I'd suggest using decimal values for
> the cases, as cache line sizes are usually given in decimal anyway. So
> just drop the "0x" instead of converting the values ;-)
> 
> 
> Jonas

Jonas, I had already sent the updated patch by the time I received your email. Is there a convention around this?
Thanks--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
