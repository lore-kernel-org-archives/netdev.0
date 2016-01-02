From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: net-rsi: Reconsider usage of variable "vap_id" in rsi_send_mgmt_pkt()
Date: Sat, 2 Jan 2016 16:12:27 +0100
Message-ID: <5687E8DB.3080706@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <5687E169.4070704@users.sourceforge.net>
 <5687E203.1070404@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5687E203.1070404@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I have taken another look at the implementation of the function "rsi_se=
nd_mgmt_pkt".
https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/tree/d=
rivers/net/wireless/rsi/rsi_91x_pkt.c?id=3De8c58e7a5a106c3d557fccd01cd4=
d1128f9bab38#n114

I find the following statement combination interesting there.

=E2=80=A6
	u8 vap_id =3D 0;
=E2=80=A6
	msg[7] |=3D cpu_to_le16(vap_id << 8);
=E2=80=A6

I would appreciate a further clarification.
Does a shift operation for a variable which contains zero indicate an o=
pen issue?

Regards,
Markus
