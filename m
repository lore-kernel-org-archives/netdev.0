From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Thu, 11 Apr 2013 12:26:50 +0200
Message-ID: <87hajdwefp.fsf@nemi.mork.no>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<1365625850.22411.1.camel@dcbw.foobar.com>
	<CACVXFVNKSszw+3VnM3hwepbTHh3gvjC+pG2SL_OsVm+1SqrNzQ@mail.gmail.com>
	<2552222.23e5DWG2Z9@linux-5eaq.site> <87txndwkx1.fsf@nemi.mork.no>
	<CACVXFVMW2Dosr0FAKCvxgUFQKmwbduiC+HqmzS1tsvAHu=G8Kg@mail.gmail.com>
	<87ppy1wfhq.fsf@nemi.mork.no>
	<CACVXFVNn9MQr6JLdin=u642Jb-2ZPfVk8YaBmNdhU0_2e7WJqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Phil Sutter <phil-ydcDiazATMQ@public.gmane.org>
To: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVNn9MQr6JLdin=u642Jb-2ZPfVk8YaBmNdhU0_2e7WJqQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Ming Lei's message of "Thu, 11 Apr 2013 18:19:16 +0800")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On Thu, Apr 11, 2013 at 6:04 PM, Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrot=
e:
>> Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>>
>> Again: What problem are you attempting to solve by removing the
>> mem_flags from the API?
>
> It is not about removing anything, we are discussing one new API
> (include the parameters) to be introduced.

Yes.  Sure.  And the original proposal was to add a new API with a
mem_flags parameter.  You proposed to add the same API, but without the
mem_flags parameter.  You did not explain why.  I still assumed that yo=
u
have some reason to propose it.  I assumed that reason must be some
problem which would be introduced by having the mem_flags parameter, an=
d
which would be solved if we instead drop it.

It seems that you are either unable or unwilling to explain your
reasons, so I'll just go ahead and drop my assumptions.  You never had
any reason and there never would be any problem.

Thanks.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
