From: john@BlueSkyTours.com
Subject: Re: r8169: slow samba performance
Date: Tue, 4 Sep 2007 15:00:11 -0600 (MDT)
Message-ID: <Pine.SOC.4.64.0709041457200.871@katana>
References: <46CC66D3.8030602@gmail.com> <20070822182116.GA5445@csy.ca>
 <46CC9290.3040501@gmail.com> <Pine.SOC.4.64.0708271631330.871@katana>
 <20070903210322.GB4444@electric-eye.fr.zoreil.com> <Pine.SOC.4.64.0709041402130.871@katana>
 <20070904203742.GB31783@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Bruce Cole <bacole@gmail.com>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat1.blueskytours.com ([12.96.192.180]:57880 "HELO
	volcano.blueskytours.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with SMTP id S1753679AbXIDVAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 17:00:13 -0400
In-Reply-To: <20070904203742.GB31783@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 4 Sep 2007, Francois Romieu wrote:

> john@BlueSkyTours.com <john@BlueSkyTours.com> :
> [...]
>> 20070903-2.6.23-rc5-r8169-test.patch applied against 2.6.23-rc5 works fine.
>> Performance is acceptable.
>
> Does "acceptable" mean that there is a noticeable difference when compared
> to the patch based on a busy-waiting loop ?


Without this patch, latency in bringing up emacs, or in display of pages in
firefox is extremely high.  With the patch, latency is pretty much what I
see when using an old tulip based NIC.

Is there a specific test you wish me to try?


>> Would you like me to *just* try patches 1 & 2, to help narrow down anything?
>
> I expect patch #2 alone to be enough to enhance the performance. If it gets
> proven, the patch would be a good candidate for a quick merge upstream.


Okay, I will build another kernel with just #2 applied.


John


