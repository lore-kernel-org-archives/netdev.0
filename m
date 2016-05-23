From: David Binderman <linuxdev.baldrick@gmail.com>
Subject: drivers/net/ethernet/qlogic/qed/qed_dcbx.c:210: pointless test ?
Date: Mon, 23 May 2016 12:11:30 +0100
Message-ID: <CAMzoamY7fh8Lyzm0njDy0fUqTZSjwDrDbZ60kZ=1XpupSBfG3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
	everest-linux-l2@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dcb314@hotmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello there,

drivers/net/ethernet/qlogic/qed/qed_dcbx.c:210:16: warning: comparison
is always false due to limited range of data type [-Wtype-limits]

Source code is

       if (priority < 0) {

but

    u8 tc, priority, priority_map;


Regards

David Binderman
