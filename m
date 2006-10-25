From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [RFC] [PATCH 1/3] adds iso3166-1 support
Date: Wed, 25 Oct 2006 11:09:48 -0400
Message-ID: <43e72e890610250809se053ceey5e1ed99d1f291ca9@mail.gmail.com>
References: <43e72e890610231545n389d8a6dy89bb476101953234@mail.gmail.com>
	 <ehmfij$99h$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.237]:25007 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1030465AbWJYPJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 11:09:50 -0400
Received: by wr-out-0506.google.com with SMTP id i4so18251wra
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2006 08:09:49 -0700 (PDT)
To: "Anand Kumria" <wildfire@progsoc.org>
In-Reply-To: <ehmfij$99h$1@sea.gmane.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/24/06, Anand Kumria <wildfire@progsoc.org> wrote:
> On Mon, 23 Oct 2006 18:45:23 -0400, Luis R. Rodriguez wrote:
>
> > iso3166-1
> >
> > ISO 3166-1, as part of the ISO 3166 standard, provides codes for the names
> > of countries and dependent areas. It was first published in 1974 by
> > the International Organization for Standardization (ISO) and defines three
> > different codes for each area:
>
> [snip]
>
> +       r |= iso3166_1_add(887, "YE", "YEM",
> +               "Yemen");
> +       r |= iso3166_1_add(891, "CS", "SCG",
> +               "Serbia and Montenegro");
> +       r |= iso3166_1_add(894, "ZM", "ZMB",
> +               "Zambia");
>
>
> According to the ISO, at:
>
> <http://www.iso.org/iso/en/commcentre/pressreleases/2006/Ref1031.html>
>
> and
>
> <http://www.iso.org/iso/en/prods-services/iso3166ma/03updates-on-iso-3166/nlv12-div.html>
>
> Serbia and Montenegro have been allocated new codes,
> RS and ME respectively.

Will update accordingly, thanks.

> Is this ISO3166 stuff supposed to track the standard?

Yes.

> If so, what happens when a country splits or two join together?

We update it.

> Will that require lock-step updates to user-space, or will it be insulated
> by this changes?

I didn't intend on having a userspace update this as I figured these
updates are rare and could just go with a new kernel release, and as
this would currently only be used for regulatory domain control it
should't have a negative impact. If there are more modules which can
make use of this then perhaps we can consider a more robust interface.

  Luis
