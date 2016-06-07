From: David Binderman <linuxdev.baldrick@gmail.com>
Subject: linux-4.7-rc2/drivers/net/wireless/ath/ath6kl/wmi.c:2547]: (style)
 Redundant condition
Date: Tue, 7 Jun 2016 16:13:48 +0100
Message-ID: <CAMzoamY2uhXDsLsE2o8mCF923XXWoGp3oF_AMmVnDY=EuachZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: kvalo@qca.qualcomm.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dcb314@hotmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello there,

linux-4.7-rc2/drivers/net/wireless/ath/ath6kl/wmi.c:2547]: (style)
Redundant condition: If 'EXPR <= 7', the comparison 'EXPR < 8' is
always true.

Source code is

    if (!((params->user_pri < 8) &&
          (params->user_pri <= 0x7) &&

This might be a possible cut'n'paste error. Also in the same file

[drivers/net/wireless/ath/ath6kl/wmi.c:1220]: (style) Variable 'rate'
is assigned a value that is never used.
[drivers/net/wireless/ath/ath6kl/wmi.c:1484]: (style) Variable
'new_threshold' is assigned a value that is never used.
[drivers/net/wireless/ath/ath6kl/wmi.c:3521]: (style) Variable 'ret'
is assigned a value that is never used.

Regards

David Binderman
