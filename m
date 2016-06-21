From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next v3 1/5] json_writer: allow base json
 data type to be array or object
Date: Tue, 21 Jun 2016 09:52:44 -0700
Message-ID: <20160621095244.6563e26b@xeon-e3>
References: <1466491187-8536-1-git-send-email-roopa@cumulusnetworks.com>
	<1466491187-8536-2-git-send-email-roopa@cumulusnetworks.com>
	<20160621091210.092baa99@xeon-e3>
	<CACcJQnTPheYi488FBYyZu=nYHKghxDbyeEM0pWM73ZcdBGU6Rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Julien Fortin <julien@cumulusnetworks.com>
To: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34983 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937AbcFURAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 13:00:31 -0400
Received: by mail-pa0-f42.google.com with SMTP id hl6so7973480pac.2
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 09:59:49 -0700 (PDT)
In-Reply-To: <CACcJQnTPheYi488FBYyZu=nYHKghxDbyeEM0pWM73ZcdBGU6Rg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Jun 2016 09:24:50 -0700
Anuradha Karuppiah <anuradhak@cumulusnetworks.com> wrote:

> On Tue, Jun 21, 2016 at 9:12 AM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> > On Mon, 20 Jun 2016 23:39:43 -0700
> > Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
> >
> >> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
> >>
> >> This patch adds a type qualifier to json_writer. Type can be a
> >> json object or array. This can be extended to other types like
> >> json-string, json-number etc in the future.
> >>
> >> Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
> >
> > Since json writer is not used in many places yet, why not just
> > get rid of the automatic object in the constructor.
> 
> I wanted to force the external api to start with an json-object or
> json-array. It reduces the chance of mistakes vs. a typeless
> constructor. With a typeless constructor you can accidentally end up
> with a json output that doesn't pass json lint; especially if optional
> params are being suppressed at different places.

Still, this is not how jsonwriter works in .NET, Android, or Java.
It is easily confusing to developers if similar API's behave
differently.  Kind of like if printf() always appended a new line
on some platforms.
