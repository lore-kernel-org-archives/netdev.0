From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Strange TCP behavior over HSDPA
Date: Tue, 29 Dec 2009 12:16:24 +0000
Message-ID: <20091229121624.GC7209@ff.dom.local>
References: <20091229083050.GA7209@ff.dom.local> <4B39D30F.8090006@gmail.com> <20091229105748.GB7209@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:64927 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbZL2MQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 07:16:32 -0500
Received: by fxm25 with SMTP id 25so5194493fxm.21
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2009 04:16:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20091229105748.GB7209@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 29, 2009 at 10:57:48AM +0000, Jarek Poplawski wrote:
> Did you try to turn off TCP window scaling btw? Anyway, under the
> tunnel ([2]), when SACK worked, it saved you a lot of retransmits.

Hmm... Actually, after re-checking, there weren't much more of those
retransmits at all. In [1] there was one more packet lost, so it took
a bit longer. In [2] (with SACK) the retransmit started earlier and
the rcv window was unchanged. So, it rather looks like differences
in timing of TCP recovery techniques.

Jarek P.
