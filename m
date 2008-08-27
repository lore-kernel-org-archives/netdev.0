From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: about Linux adaptivly adjusting ssthresh
Date: Wed, 27 Aug 2008 15:48:44 -0700
Message-ID: <1e41a3230808271548w15164eadt1042f37bf2df7e6f@mail.gmail.com>
References: <1e41a3230804151540i1f7cee4dva6adc6ef25dae546@mail.gmail.com>
	 <20080416.012732.152357000.davem@davemloft.net>
	 <Pine.LNX.4.64.0804161203590.17123@wrl-59.cs.helsinki.fi>
	 <20080416.023551.70464279.davem@davemloft.net>
	 <000001c90852$a1c19a50$a05ee183@D2GT6T71>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: wenji@fnal.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:12503 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753038AbYH0Wsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 18:48:45 -0400
Received: by an-out-0708.google.com with SMTP id d40so15876and.103
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2008 15:48:44 -0700 (PDT)
In-Reply-To: <000001c90852$a1c19a50$a05ee183@D2GT6T71>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 27, 2008 at 7:38 AM, Wenji Wu <wenji@fnal.gov> wrote:
>
> Hi, all,
>
> Could anybody help me out with Linux adaptively adjusting ssthresh? Thanks
> in advance.
>
> I understand that the latest Linux is able to adaptively adjust ssthresh to
> avoid retransmission. Could anybody tell me which algorithms have been
> implemented for the adaptive ssthresh adjust?


A little more detail would be helpful.  Are you referring to caching
ssthresh between connections, or something going on during a
connection?  Various congestion control modules use ssthresh
differently, so a comprehensive answer would be difficult.

  -John
