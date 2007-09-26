From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Re: Userspace network stack and netchannels.
Date: Wed, 26 Sep 2007 12:43:49 +0200
Message-ID: <7e63f56c0709260343y3fc5a9bdxe64fd251e682c883@mail.gmail.com>
References: <20070925180043.GA16698@2ka.mipt.ru>
	 <7e63f56c0709251220s12ab10b5pade5b2c90fa4a8b9@mail.gmail.com>
	 <20070926085303.GB13187@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:6668 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757669AbXIZKnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2007 06:43:51 -0400
Received: by py-out-1112.google.com with SMTP id u77so4098837pyb
        for <netdev@vger.kernel.org>; Wed, 26 Sep 2007 03:43:50 -0700 (PDT)
In-Reply-To: <20070926085303.GB13187@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/26/07, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> > > http://tservice.net.ru/~s0mbre/blog/devel/networking/2006_10_26.html
> > > http://tservice.net.ru/~s0mbre/blog/devel/networking/2006_12_21.html
> > >
> >
> > Very interesting. Are there any details of your benchmarking available,
> > namely, how it was done?
> > Have you some comparison profiling data (oprofile) to figure out where
> > the advantages are coming from?

> My analysis says that reduced number of syscalls is
> main improvement factor,
Great! Just oprofile of the comparison tests is of my curiosity.

> but different (non-rfc-compliant) congestion
> control allows faster start and faster recovery.

People like compliance to standards, even if it decreases performance.
:) Take care.

-- 
Sincerely,
Robert Iakobashvili,
coroberti %x40 gmail %x2e com
...........................................................
http://curl-loader.sourceforge.net
A web testing and traffic generation tool.
