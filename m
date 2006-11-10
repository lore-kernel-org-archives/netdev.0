From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: Re: bcm43xx-d80211 broadcast reception with WPA
Date: Fri, 10 Nov 2006 09:27:49 +0100
Message-ID: <a32f33a40611100027y11e5a524j7ddae7776f3d040c@mail.gmail.com>
References: <ej09qf$2nv$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.203]:47407 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1946033AbWKJI1w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 03:27:52 -0500
Received: by nz-out-0102.google.com with SMTP id l1so252383nzf
        for <netdev@vger.kernel.org>; Fri, 10 Nov 2006 00:27:52 -0800 (PST)
To: "Paul Hampson" <Paul.Hampson@pobox.com>
In-Reply-To: <ej09qf$2nv$1@sea.gmane.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> I've been backporting the bcm43xx-d80211 driver to whatever the released
> 2.6 kernel was using the rt2x00 project's d80211 stack (equivalent to
> current wireless-dev but with a workaround for not having a ieee80211_dev
> pointer and still using the _tfm interface instead of the _cypher interface.)

Just a note about that stack, it should only be used on kernel 2.6.17
and higher.
Previous kernels had a bug that caused the stack to crash.
The _tfm cipher interface will soon change, since I haven't had time to update
the stack to the latest version yet, I'll do that this weekend.

 Ivo
