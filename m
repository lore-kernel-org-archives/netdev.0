From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH RESEND v3 0/2] qmi_wwan: subdriver support (parts 4/5 and 5/5 previously)
Date: Fri,  9 Mar 2012 12:35:04 +0100
Message-ID: <1331292906-7467-1-git-send-email-bjorn@mork.no>
References: <20120308185324.GA13836@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Dan Williams <dcbw@redhat.com>,
	Oliver Neukum <oliver@neukum.org>, netdev@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:39276 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751077Ab2CILfr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2012 06:35:47 -0500
In-Reply-To: <20120308185324.GA13836@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resending patch 4 and 5 of the previous five patch series, to be applie=
d
to usb-next as already discussed with the usb and network maintainers.

These patches depend on the following commit currently in net-next
(and linux-next):

  9b28ecd net: usb: qmi_wwan: New driver for Huawei QMI based WWAN devi=
ces

I have verified that they apply cleanly to the current (5db51b5) usb-ne=
xt
branch after cherry-picking this commit from net-next.


Didn't know how to handle the numbering of this set, which is a partial
resend.  Part 1/2 of this set was previously submitted as part 4/5, and
part 2/2 was previously submitted as part 5/5.  Sorry for the confusion=
=2E
I've just learned yet another issue to be careful with.  Won't do parti=
al
resending like that anymore...

I'm CCing this to netdev for information, but have set=20
"X-Patchwork-Hint: ignore" to prevent the patches from ending up in
netdev patchwork.  Hope that's OK.


Thanks.



Bj=C3=B8rn Mork (2):
  net: qmi_wwan: support devices having a shared QMI/wwan interface
  net: qmi_wwan: add Gobi and Pantech UML290 device IDs

 drivers/net/usb/qmi_wwan.c |  248 ++++++++++++++++++++++++++++++++++++=
+++++---
 1 files changed, 232 insertions(+), 16 deletions(-)

--=20
1.7.9.1
