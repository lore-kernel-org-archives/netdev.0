From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Recurring trace from tcp_fragment()
Date: Thu, 4 Jun 2015 15:34:58 -0400
Message-ID: <CADVnQyn20JyAQqohihu5q=gfLHeQAAtn_VABMsZCvNPdQ3R+uw@mail.gmail.com>
References: <CFCC0DCC-4080-4195-9BA9-0860D9701805@fastly.com>
	<CADVnQyngTDVYMhmQq=pjS3LrdQ+HXyizujiOkmgXxTjQ0QKH8A@mail.gmail.com>
	<5E30A40E-EC6C-4D37-AB49-04BF40EEFBFC@fastly.com>
	<CADVnQy=rwKG_ddduixcee1D4HaaSBBk=X=2Htmdow0k6Cbxhzg@mail.gmail.com>
	<904FADEB-C1EB-4384-BA47-0EB0273AFB71@fastly.com>
	<CADVnQymCSGyyOqdO2HOap+_6zsfy99-3CbgxnQTfGakRYNoteQ@mail.gmail.com>
	<55707E38.4090506@fastly.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Grant Zhang <gzhang@fastly.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:36188 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751672AbbFDTe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 15:34:59 -0400
Received: by oihb142 with SMTP id b142so38414675oih.3
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 12:34:58 -0700 (PDT)
In-Reply-To: <55707E38.4090506@fastly.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 4, 2015 at 12:35 PM, Grant Zhang <gzhang@fastly.com> wrote:
> Hi Neal,
>
> Unfortunately with the patch we still see the same stack trace. Attached is
> the TcpExtTCPSACKReneging with the patch, captured with 60 seconds interval.
> Its value is incremented at an similar speed as before, about 30/minute.
>
> If you want to collect any other data, please feel free to let me know.

OK, very interesting. Thank you so much for testing that patch. We
will work on coming up with another patch to try to address this.

Thanks!

neal
