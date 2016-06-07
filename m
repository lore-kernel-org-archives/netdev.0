From: David Binderman <linuxdev.baldrick@gmail.com>
Subject: linux-4.7-rc2/drivers/net/ethernet/freescale/fman/fman.c:2329]:
 (style) Redundant condition
Date: Tue, 7 Jun 2016 10:41:09 +0100
Message-ID: <CAMzoamZfyCrPFWVr-nh3HvG6v7UXT_SWCfxF0pTjNeOuX4w7uA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dcb314@hotmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello there,

linux-4.7-rc2/drivers/net/ethernet/freescale/fman/fman.c:2329]:
(style) Redundant condition: fman.state.port_mfl[mac_id]. '!A || (A &&
B)' is equivalent to '!A || B'

Source code is

    if ((!fman->state->port_mfl[mac_id]) ||
        (fman->state->port_mfl[mac_id] &&
        (mfl <= fman->state->port_mfl[mac_id]))) {

Suggest new code

    if ((!fman->state->port_mfl[mac_id]) ||
        (mfl <= fman->state->port_mfl[mac_id])) {

Regards

David Binderman
