From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: A Linux TCP SACK Question
Date: Fri, 4 Apr 2008 11:07:40 -0700
Message-ID: <1e41a3230804041107i2bce2c59oc6f2a55d7ca78b0f@mail.gmail.com>
References: <fc471cb97cfd.47f5520e@fnal.gov>
	 <1e41a3230804040927j3ce53a84u6a95ec37dff1b5b0@mail.gmail.com>
	 <000001c8967c$496efa20$c95ee183@D2GT6T71>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wenji@fnal.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.186]:41890 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751637AbYDDSHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 14:07:44 -0400
Received: by rn-out-0910.google.com with SMTP id e24so283285rng.1
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2008 11:07:41 -0700 (PDT)
In-Reply-To: <000001c8967c$496efa20$c95ee183@D2GT6T71>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 4, 2008 at 10:49 AM, Wenji Wu <wenji@fnal.gov> wrote:
>  I was thinking that if the reordered ACKs/SACKs cause confusion in the
>  sender, and sender will unnecessarily reduce either the CWND or the
>  TCP_REORDERING threshold. I might need to take a serious look at the SACK
>  implementation.

It sounds very likely that you're encountering a bug or thinko in the sack code.

This actually brings to mind an old topic -- NCR (RFC4653).  There was
some discussion of implementing this, which I think is simpler and
more robust than Linux's current reordering threshold calculation.

  -John
