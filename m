From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: [PATCH] Force UNIX domain sockets to be built in
Date: Mon, 31 Dec 2007 17:17:19 +0100
Message-ID: <64bb37e0712310817g621d818dyebbf2228063d4d5f@mail.gmail.com>
References: <alpine.LSU.0.999.0712311300020.3686@be1.lrz>
	 <20071231144255.GB13803@does.not.exist>
	 <64bb37e0712310755k2446e67eq81d31cd476eb75e3@mail.gmail.com>
	 <200712311659.14847.mb@bu3sch.de>
	 <20071231160140.579f0fb2@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michael Buesch" <mb@bu3sch.de>, "Adrian Bunk" <bunk@kernel.org>,
	"Bodo Eggert" <7eggert@gmx.de>,
	"Jan Engelhardt" <jengelh@computergmbh.de>, devzero@web.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Alan Cox" <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:22903 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216AbXLaQRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 11:17:20 -0500
Received: by py-out-1112.google.com with SMTP id u52so9084583pyb.10
        for <netdev@vger.kernel.org>; Mon, 31 Dec 2007 08:17:19 -0800 (PST)
In-Reply-To: <20071231160140.579f0fb2@the-village.bc.nu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 31, 2007 5:01 PM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> > I'd say the practical advantage to the user would be almost zero.
> > Which distribution is going to enable this option and defacto
> > banning external modules?
>
> It would be a real nuisance for developing code let alone for using it.

Hmm... Why?
a) this could be disabled during development if you want this
b) this would even only affect development if you add new code that
now needs a EXPORT_SYMBOL that was removed on an earlier build. And
right now this would also need to trigger a rerun of depmod. And the
same trigger could redo this garbage collect.

Or am I missing something obvious?

> The entries are currently far bigger than is needed and fixing that would
> be much more productive.

Can't say anything about that. ;)

Torsten
