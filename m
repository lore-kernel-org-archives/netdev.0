From: Hemant-vilas RAMDASI <hemant.ramdasi@stericsson.com>
Subject: about phonet pipe controller
Date: Wed, 12 Oct 2011 09:25:01 +0200
Message-ID: <81C3A93C17462B4BBD7E272753C105791EAACAE76F@EXDCVYMBSTM005.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Srinidhi KASAGAR <srinidhi.kasagar@stericsson.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "remi.denis-courmont@nokia.com" <remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:48753 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751401Ab1JLHZM convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Oct 2011 03:25:12 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Remi,

You have mentioned in the
"a015f6f: Phonet: kill the ST-Ericsson pipe controller Kconfig",
that "Support for manually enabling the pipe flow is removed as it
did not work properly, does not fit well with the socket API, and
I am not aware of any use at the moment.."

On STE U8500 modem, you must first create pipe in disabled state, then do
local link configuration (does't work when pipe is enabled) & then enable pipe.

Because of this connect() cannot be used anymore and it needs to be modified to
reintroduce pipe-controller functionality again.

Do you have any suggestions?

Regards,
Hemant Ramdasi
