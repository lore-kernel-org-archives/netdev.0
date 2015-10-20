From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] usbnet: removed USB_USBNET as a config option
Date: Tue, 20 Oct 2015 13:03:22 +0200
Message-ID: <87fv15u7id.fsf@nemi.mork.no>
References: <1445257387-4278-1-git-send-email-oneukum@suse.com>
	<87oafuu0ru.fsf@nemi.mork.no> <1445322539.2246.1.camel@suse.com>
	<87k2qiszfv.fsf@nemi.mork.no> <1445336670.2246.11.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:37248 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752386AbbJTLDj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 07:03:39 -0400
In-Reply-To: <1445336670.2246.11.camel@suse.com> (Oliver Neukum's message of
	"Tue, 20 Oct 2015 12:24:30 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oneukum@suse.com> writes:
> On Tue, 2015-10-20 at 10:43 +0200, Bj=C3=B8rn Mork wrote:
>
>> So we might need to move cdc_parse_cdc_header() out of usbnet.c afte=
r
>> all. Keeping it there creates an unnecessary "select" mess.  But I d=
on't
>> know where to put it...  Either a common CDC helper module or the US=
B
>> core I guess.
>
> A common module means that the overhead of a module would be incurred=
=2E
> Do you have any other candidates that could go into a common helper
> module?

Not anything that matters. Some of the CDC notification handling could
maybe be shared by using a shoehorn on it, but I think that would make
the code less maintainable so it is not a good idea.

So, no, I don't have any other candidates. "usbcore" looks like the bes=
t
place for this function, if that is acceptable to Greg.



Bj=C3=B8rn
