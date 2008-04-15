From: "Tim Hockin" <thockin@google.com>
Subject: Re: [PATCH] [ETHTOOL]: Add support for large eeproms
Date: Tue, 15 Apr 2008 10:07:21 -0700
Message-ID: <cc96a5040804151007q6008355cl2cc85242b81f3918@mail.gmail.com>
References: <48007CA0.6030002@garzik.org> <20080414180338.GA18335@google.com>
	 <20080415.003153.30044057.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: msb@google.com, netdev@vger.kernel.org, jeff@garzik.org,
	joe@perches.com, nil@google.com, matthew@wil.cx
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:3769 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756374AbYDORJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 13:09:00 -0400
Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id m3FH7M9x027410
	for <netdev@vger.kernel.org>; Tue, 15 Apr 2008 18:07:23 +0100
Received: from wx-out-0506.google.com (wxdh27.prod.google.com [10.70.134.27])
	by zps77.corp.google.com with ESMTP id m3FH66pa013281
	for <netdev@vger.kernel.org>; Tue, 15 Apr 2008 10:07:22 -0700
Received: by wx-out-0506.google.com with SMTP id h27so1622320wxd.15
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2008 10:07:22 -0700 (PDT)
In-Reply-To: <20080415.003153.30044057.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Dave, long time!

On Tue, Apr 15, 2008 at 12:31 AM, David Miller <davem@davemloft.net> wrote:
>
>  This looks fine on the surface.
>
>  But I wonder what we can do if we have some EEPROM implementation
>  that can only write the whole time at once, and thus will fail
>  if you try to do it in pieces?  Do we have such a case?
>
>  If so this new code could cause regressions.

No device that I know of behaves that way.  It's certainly possible,
but I've never seen any sort of PROM device that has such a
requirement.

Tim
