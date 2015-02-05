From: Eliezer Tamir <eliezer.tamir-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH v2] socket.7: add description for SO_BUSY_POLL
Date: Thu, 05 Feb 2015 19:48:14 +0200
Message-ID: <54D3ACDE.5070301@linux.intel.com>
References: <20130710141835.15799.61657.stgit@ladj378.jer.intel.com> <52DD4EC6.7080208@gmail.com> <52DD5CC4.3010708@linux.intel.com> <CAKgNAki16GXAs5J5cXPzftxxrvaugOvQSamVsGe4jFQF9V=fAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-man <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Eliezer Tamir <eliezer-rsSRdLmRgNEQhDRD3CWCHA@public.gmane.org>
To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKgNAki16GXAs5J5cXPzftxxrvaugOvQSamVsGe4jFQF9V=fAQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/02/2015 15:17, Michael Kerrisk (man-pages) wrote:
> On 20 January 2014 at 18:28, Eliezer Tamir
> <eliezer.tamir-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> wrote:
>> On 20/01/2014 18:28, Michael Kerrisk (man-pages) wrote:
>>> On 07/10/2013 04:18 PM, Eliezer Tamir wrote:
>>>> Add description for the SO_BUSY_POLL socket option to the socket(7) manpage.
>>>
>>> Long after the fact, I've applied this. Thanks, Eliezer.
>>>
>>> Would you be willing also to write a patch for the POLL_BUSY_LOOP flag of
>>> poll()?
>>
>> Yes, Me or someone from our team will do that.
> 
> Hi Eliezer,
> 
> Could you or someone from your team send me a POLL_BUSY_LOOP doc patch?

Hi Michael,

Right now POLL_BUSY_LOOP is only used internally to control busylooping,
as a signal between sock_poll() and do_poll().
Our original intention was to expose that to the users of epoll().
The work on epoll() support is not finished yet.

I think we should not document this until we finalize epoll() support.

Thanks,
Eliezer
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
