From: "Steve French" <smfrench@gmail.com>
Subject: Re: [linux-cifs-client] Fwd: [PATCH] Fix CIFS compilation with CONFIG_KEYS unset
Date: Sun, 12 Oct 2008 13:47:12 -0500
Message-ID: <524f69650810121147j4ad79f77p348a3814b7f05d01@mail.gmail.com>
References: <200810121315.37203.rjw@sisk.pl>
	 <524f69650810120953t2ec8100cpdddc3ddfce0406d9@mail.gmail.com>
	 <524f69650810120957t1a81f23lf3fd75fee78e72c3@mail.gmail.com>
	 <200810121909.53233.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jeff Layton" <jlayton@redhat.com>,
	"David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
	"linux-cifs-client@lists.samba.org"
	<linux-cifs-client@lists.samba.org>, cooldavid@cooldavid.org,
	LKML <linux-kernel@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:49268 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753829AbYJLSrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Oct 2008 14:47:14 -0400
Received: by ey-out-2122.google.com with SMTP id 6so480599eyi.37
        for <netdev@vger.kernel.org>; Sun, 12 Oct 2008 11:47:12 -0700 (PDT)
In-Reply-To: <200810121909.53233.rjw@sisk.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 12, 2008 at 12:09 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> On Sunday, 12 of October 2008, Steve French wrote:
>> On Sun, Oct 12, 2008 at 11:53 AM, Steve French <smfrench@gmail.com> wrote:
>> > On Sun, Oct 12, 2008 at 8:59 AM, Jeff Layton <jlayton@redhat.com> wrote:
>> >> On Sun, 12 Oct 2008 08:40:39 -0500
>> >> "Steve French" <smfrench@gmail.com> wrote:
>> >>
>> >> Actually, I like Adrian/Rafael's fix better. I think we should avoid
>> >> cluttering up the code with #ifdef's where possible. key_put() already
>> >> is a no-op when CONFIG_KEYS is disabled. We might as well do the same
>> >> thing with key_revoke().
>> > I don't think it matters much - but we probably shouldn't be
>> > overriding global functions.
>>
>> To clarify, I like fixing it in keys.h better than overriding it in
>> cifs, but in the meantime we need an ifdef in cifs until keys.h
>> changes.
>
> Well, adding an empty definition for key_revoke() in the !CONFIG_KEYS case
> makes sense anyway IMO.

I agree.  ACKED

-- 
Thanks,

Steve
