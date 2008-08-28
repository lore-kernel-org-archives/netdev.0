From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: about Linux adaptivly adjusting ssthresh
Date: Thu, 28 Aug 2008 09:34:28 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808280928450.5170@wrl-59.cs.helsinki.fi>
References: <1e41a3230804151540i1f7cee4dva6adc6ef25dae546@mail.gmail.com>
 <20080416.012732.152357000.davem@davemloft.net>
 <Pine.LNX.4.64.0804161203590.17123@wrl-59.cs.helsinki.fi>
 <20080416.023551.70464279.davem@davemloft.net> <000001c90852$a1c19a50$a05ee183@D2GT6T71>
 <1e41a3230808271548w15164eadt1042f37bf2df7e6f@mail.gmail.com>
 <fb62ce3717a7.48b5b0a8@fnal.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: John Heffner <johnwheffner@gmail.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Wenji Wu <wenji@fnal.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35864 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884AbYH1Gea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 02:34:30 -0400
In-Reply-To: <fb62ce3717a7.48b5b0a8@fnal.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Aug 2008, Wenji Wu wrote:

> 
> > A little more detail would be helpful.  Are you referring to caching
> > ssthresh between connections, or something going on during a
> > connection?  Various congestion control modules use ssthresh
> > differently, so a comprehensive answer would be difficult.
> 
> 
> Thanks John, I am referring to the adaptive ssthresh adjusting during a 
> connection.

???

Every now and then (once we detect some losses) snd_ssthresh is set to a 
halved flightsize as given by, well, you know those standards that say 
something about it :-). So I (like John) seem to somewhat miss the point 
of your question here.

Or did you perhaps refer to rcv_ssthresh (which I wouldn't ever call 
to with a plain "ssthresh")?

-- 
 i.
