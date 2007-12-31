From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Force UNIX domain sockets to be built in
Date: Mon, 31 Dec 2007 16:38:03 +0000
Message-ID: <20071231163803.33acb647@the-village.bc.nu>
References: <alpine.LSU.0.999.0712311300020.3686@be1.lrz>
	<20071231144255.GB13803@does.not.exist>
	<64bb37e0712310755k2446e67eq81d31cd476eb75e3@mail.gmail.com>
	<200712311659.14847.mb@bu3sch.de>
	<20071231160140.579f0fb2@the-village.bc.nu>
	<64bb37e0712310817g621d818dyebbf2228063d4d5f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Michael Buesch" <mb@bu3sch.de>, "Adrian Bunk" <bunk@kernel.org>,
	"Bodo Eggert" <7eggert@gmx.de>,
	"Jan Engelhardt" <jengelh@computergmbh.de>, devzero@web.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:37738 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750905AbXLaQqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 11:46:31 -0500
In-Reply-To: <64bb37e0712310817g621d818dyebbf2228063d4d5f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 31 Dec 2007 17:17:19 +0100
"Torsten Kaiser" <just.for.lkml@googlemail.com> wrote:

> a) this could be disabled during development if you want this
> b) this would even only affect development if you add new code that
> now needs a EXPORT_SYMBOL that was removed on an earlier build. And
> right now this would also need to trigger a rerun of depmod. And the
> same trigger could redo this garbage collect.
> 
> Or am I missing something obvious?

Development is not a phase seperate from use or distribution. A lot of
module testers for distributions will not be compiling their own modules
but loading in ones to test provided by their vendor - which may of
course then need different ksyms

Alan
