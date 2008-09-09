From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: Internet-Draft on Port Randomisation
Date: Mon, 08 Sep 2008 21:58:44 -0700
Message-ID: <48C60284.2070402@vyatta.com>
References: <28fa9c5e0809082107p7a33dc4fod344fde212e1d710@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eugene Teo <eteo@redhat.com>
To: Eugene Teo <eugeneteo@kernel.sg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:55680 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751520AbYIIE6i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 00:58:38 -0400
In-Reply-To: <28fa9c5e0809082107p7a33dc4fod344fde212e1d710@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eugene Teo wrote:
> Has anyone read this Internet-Draft?
> http://www.gont.com.ar/drafts/port-randomization/draft-ietf-tsvwg-port-randomization-02.txt
>
> In this memo, there are descriptions of four different ephemeral port
> randomisation algorithms (see page 17).
>
> Algo #1 and #2 are simple port randomisation algorithms. Algo #3 is
> what we have in Linux. The memo suggested algorithm #4, double-hash
> randomisation algorithm, which is an improvement to algo #3 (see page
> 15).
>
> Does anyone have any thought about the improved algorithm? Is this
> worth implementing, 
No the added lock overhead of a global next free port array is not worth 
it. Think of big web server under
DoS pressure. The existing port search can run in parallel, Algo #4 was 
suggested by people
who don't work on a real SMP OS.
