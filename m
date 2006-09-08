From: "Gnome42 Gnome42" <gnome42@gmail.com>
Subject: IPSec broken in 2.6.18-rc4-mm3
Date: Fri, 8 Sep 2006 12:26:17 -0400
Message-ID: <fa4052ef0609080926j5bbae070mccb9699f0e5eb1fb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.193]:52665 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1750912AbWIHQ0S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Sep 2006 12:26:18 -0400
Received: by nz-out-0102.google.com with SMTP id n1so332952nzf
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2006 09:26:18 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Folks,

(please CC me ...)

IPSec got broken in 2.6.18-rc4-mm3+, 2.6.18-rc4-mm2 works and
2.6.18-rc5 also works.

The tunnel looks like its established correctly in the racoon logs and
the traffic is encrypted on the wire. However, the other side does not
decrypt the traffic it just seems to disappear.

I have confirmed this problem exists between two linux boxen and a
Netopia router as well.

The git-net.patch increased in size by about 50% between
2.6.18-rc4-mm2 and 2.6.18-rc4-mm3 (likely suspect?), but i was unable
to simply patch -R it cleanly.

Suggestions?

Shane
